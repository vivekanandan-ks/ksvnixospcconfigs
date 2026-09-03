{ self, ... }: {
  flake = {
    homeModules.nonDroid.mango-virtual-monitor = {
      lib,
      pkgs,
      ...
    }: let
      # Self-contained toggle script with all runtime dependencies baked in
      toggleVirtMon = pkgs.writeShellApplication {
        name = "toggle-virtmon";
        runtimeInputs = with pkgs; [
          wl-mirror
          libnotify
          procps
          ripgrep
          coreutils
        ];
        text = ''
          # Check if HEADLESS-1 exists in MangoWM using ripgrep
          if mmsg get all-monitors | rg -q '"name":"HEADLESS-1"'; then
            # --- TEARDOWN ---
            pkill -f "wl-mirror.*HEADLESS-1" || true
            mmsg dispatch destroy_all_virtual_output
            notify-send -a "Mango Virtual Monitor" -i video-display "Virtual Monitor Stopped" "Destroyed HEADLESS-1."
          else
            # --- SETUP ---
            start_time=$(date +%s%3N)
            mmsg dispatch create_virtual_output

            # Wait until MangoWM registers HEADLESS-1 (up to 10.0s, checking every 100ms)
            created=false
            for _ in {1..100}; do
              if mmsg get all-monitors | rg -q '"name":"HEADLESS-1"'; then
                created=true
                break
              fi
              sleep 0.1
            done

            end_time=$(date +%s%3N)
            elapsed_ms=$((end_time - start_time))
            elapsed_sec=$((elapsed_ms / 1000))
            elapsed_tenths=$(((elapsed_ms % 1000) / 100))
            elapsed="''${elapsed_sec}.''${elapsed_tenths}s"

            if [ "$created" = true ]; then
              # Launch wl-mirror with auto-retry in background (up to 10.0s)
              (
                for _ in {1..40}; do
                  if wl-mirror HEADLESS-1; then
                    break
                  fi
                  sleep 0.25
                done
              ) &

              notify-send -a "Mango Virtual Monitor" -i video-display "Virtual Monitor Active" "HEADLESS-1 ready & mirrored (''${elapsed})."
            else
              notify-send -u critical -a "Mango Virtual Monitor" -i dialog-error "Virtual Monitor Failed" "HEADLESS-1 did not appear within 10s."
            fi
          fi
        '';
      };
    in {
      # Install toggle-virtmon and wl-mirror onto PATH
      home.packages = [
        toggleVirtMon
        pkgs.wl-mirror
      ];

      wayland.windowManager.mango.settings = {
        # Float, resize to 16:9, and pin across all workspaces (isglobal:1)
        windowrule = lib.mkAfter [
          "isglobal:1,isfloating:1,width:640,height:360,appid:.*wl_mirror.*"
        ];

        # Keybindings for the Virtual Monitor
        bind = lib.mkAfter [
          # Toggle virtual monitor & mirror
          "SUPER, v, spawn, toggle-virtmon"

          # Send focused window to the virtual monitor
          "SUPER+SHIFT, v, tagmon, HEADLESS-1"

          # Focus the virtual monitor
          "SUPER+CTRL, v, focusmon, HEADLESS-1"
        ];
      };
    };
  };
}
