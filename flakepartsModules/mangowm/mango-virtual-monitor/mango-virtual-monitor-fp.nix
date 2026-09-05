_: {
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
          # Find any active or existing headless monitor
          current_mon=$(mmsg get all-monitors | rg -o '"name":"(HEADLESS-[0-9]+)"' -r '$1' | head -n 1 || true)

          if [ -n "$current_mon" ]; then
            # --- TEARDOWN ---
            pkill -f "wl-mirror.*HEADLESS-" || true
            mmsg dispatch destroy_all_virtual_output
            notify-send -a "Mango Virtual Monitor" -i video-display "Virtual Monitor Stopped" "Destroyed $current_mon."
          else
            # --- SETUP ---
            start_time=$(date +%s%3N)
            mmsg dispatch create_virtual_output

            # Wait until MangoWM registers the new headless output (up to 10.0s, checking every 100ms)
            created_mon=""
            for _ in {1..100}; do
              created_mon=$(mmsg get all-monitors | rg -o '"name":"(HEADLESS-[0-9]+)"' -r '$1' | head -n 1 || true)
              if [ -n "$created_mon" ]; then
                break
              fi
              sleep 0.1
            done

            end_time=$(date +%s%3N)
            elapsed_ms=$((end_time - start_time))
            elapsed_sec=$((elapsed_ms / 1000))
            elapsed_tenths=$(((elapsed_ms % 1000) / 100))
            elapsed="''${elapsed_sec}.''${elapsed_tenths}s"

            if [ -n "$created_mon" ]; then
              # Launch wl-mirror in background (auto-retry on fast startup fail, auto-exit on teardown)
              (
                for _ in {1..40}; do
                  # 1. Abort immediately if the monitor was destroyed or teardown began
                  if ! mmsg get all-monitors | rg -q "\"name\":\"$created_mon\""; then
                    break
                  fi

                  start_run=$(date +%s)
                  wl-mirror "$created_mon" || true
                  runtime=$(( $(date +%s) - start_run ))

                  # 2. If it was active for >= 1s, it was closed intentionally — do not retry
                  if [ "$runtime" -ge 1 ]; then
                    break
                  fi

                  # 3. Check again if output was removed during startup
                  if ! mmsg get all-monitors | rg -q "\"name\":\"$created_mon\""; then
                    break
                  fi

                  sleep 0.25
                done
              ) &

              notify-send -a "Mango Virtual Monitor" -i video-display "Virtual Monitor Active" "$created_mon ready & mirrored (''${elapsed})."
            else
              notify-send -u critical -a "Mango Virtual Monitor" -i dialog-error "Virtual Monitor Failed" "Virtual monitor did not appear within 10s."
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
          "SUPER+SHIFT, v, tagmon, HEADLESS-.*"

          # Focus the virtual monitor
          "SUPER+CTRL, v, focusmon, HEADLESS-.*"
        ];
      };
    };
  };
}
