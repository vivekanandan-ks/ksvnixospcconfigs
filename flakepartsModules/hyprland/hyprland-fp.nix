{...}: {
  flake = {
    nixosModules.hyprland = {
      inputs,
      pkgs,
      pkgs-unstable,
      ...
    }: {
      programs.hyprland = {
        enable = true;
        xwayland.enable = true; # default true
        #package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        package = pkgs-unstable.hyprland;
        #portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
        portalPackage = pkgs-unstable.xdg-desktop-portal-hyprland;
      };
    };

    homeModules.nonDroid.hyprland = {
      inputs,
      lib,
      pkgs,
      self,
      pkgs-unstable,
      ...
    }: {


      programs.hyprland-qt-support = {
        enable = true;
        package = pkgs-unstable.hyprland-qt-support;
      };

      home.packages = [
        #inputs.hyprnix.packages.${pkgs.stdenv.hostPlatform.system}.hyprpolkitagent
        #inputs.hyprnix.packages.${pkgs.stdenv.hostPlatform.system}.hyprlock
      ];

      wayland.windowManager.hyprland = {
        enable = true;
        package = null;
        portalPackage = null;
        #configType = "lua";
        plugins = [
          #inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprbars
          #inputs.hypr-dynamic-cursors.packages.${pkgs.stdenv.hostPlatform.system}.hypr-dynamic-cursors
          # inputs.gloview.packages.${pkgs.stdenv.hostPlatform.system}.gloview
          # inputs.Hyprspace.packages.${pkgs.stdenv.hostPlatform.system}.Hyprspace
          #inputs.hyprexpo.packages.${pkgs.stdenv.hostPlatform.system}.hyprexpo
        ];
        systemd = {
          enable = true;
          variables = ["--all"];
        };

        settings = {

          misc = {
            # Window swallowing
            # (i.e. children window causes parent to be hidden)
            enable_swallow = true; # Enable window swallowing
            swallow_regex = "kitty|ghostty"; # Windows for which swallowing is applied

            # dpms
            mouse_move_enables_dpms = true; # Enable DPMS on mouse/touchpad action
            key_press_enables_dpms = true; # Enable DPMS on keyboard action
            disable_autoreload = true; # Autoreload is unnecessary on NixOS, because the configuration file is read-only link
          };

          general = {
            # gaps
            gaps_in = 4;
            gaps_out = 8;
          };

          input = {
            follow_mouse = 1; # following mouse is actually helpful :-)
          };

          animations = {
            enabled = true;
            bezier = [
              "smoothOut, 0.36, 0, 0.66, -0.56"
              "smoothIn, 0.25, 1, 0.5, 1"
              "overshot, 0.4,0.8,0.2,1.2"
            ];

            animation = [
              "windows, 1, 3, overshot, slide"
              "windowsOut, 1, 3, smoothOut, slide"
              "border,1,10,default"

              "fade, 1, 10, smoothIn"
              "fadeDim, 1, 10, smoothIn"
              "workspaces,1,4,overshot,slidevert"
            ];

          };

          decoration = {
            # fancy corners
            rounding = 7;

            blur = {
              enabled = true;
              size = 5;
              passes = 3;
              ignore_opacity = true;
              new_optimizations = 1;
              xray = true;
              popups = true;
              popups_ignorealpha = 0.2;
              #contrast = 0.7;
              #brightness = 0.8;
              #vibrancy = 0.2;
              #special = true; # expensive, but helps distinguish special workspaces
            };
          };
          exec-once = [
            "systemctl --user start noctalia.service"
            #"systemctl --user start hyprpolkitagent"
          ];
          bind = [
            #"SUPER, TAB, hyprexpo:expo, toggle"
            "CTRL ALT, Delete, exec, ${lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.ksvNoctalia} ipc call sessionMenu toggle"
          ];



          /*"plugin:hyprexpo" = {
            preview_mode = "live";
            window_icon_enable = true;
          };*/
        };
      };
    };
  };
}
