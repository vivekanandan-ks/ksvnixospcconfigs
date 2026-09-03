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
            mmsg dispatch create_virtual_output

            # Brief pause for wlroots to announce output
            sleep 0.2

            # Launch preview window
            wl-mirror HEADLESS-1 &

            notify-send -a "Mango Virtual Monitor" -i video-display "Virtual Monitor Active" "HEADLESS-1 ready & mirrored."
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
          "isglobal:1,isfloating:1,width:640,height:360,appid:wl-mirror"
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
