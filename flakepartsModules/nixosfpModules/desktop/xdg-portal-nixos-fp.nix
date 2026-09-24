_: {
  flake = {
    nixosModules.xdg-portal = {
      lib,
      pkgs,
      pkgs-unstable,
      ...
    }: {
      xdg.portal = {
        enable = true;

        # Keep WLR enabled as primary/fallback portal for screencast & screenshot
        wlr = {
          enable = true;
          settings = {
            screencast = {
              chooser_type = "dmenu";
              chooser_cmd = "${pkgs-unstable.wofi}/bin/wofi --dmenu --prompt 'Select Screen to Share'";
              # Alternative with rofi if preferred:
              # chooser_cmd = "${pkgs-unstable.rofi}/bin/rofi -dmenu -i -p 'Select Screen to Share'";
            };
          };
        };

        extraPortals = [
          # pkgs-unstable.xdg-desktop-portal-luminous
          pkgs-unstable.xdg-desktop-portal-gtk
        ];

        config = {
          common.default = ["gtk"];

          # Prioritize WLR for Mango, fallback to GTK
          mango.default = lib.mkForce ["wlr" "gtk"];

          # Prioritize Luminous for Mango, fallback to WLR, then GTK
          # mango = {
          #   default = lib.mkForce ["luminous" "wlr" "gtk"];
          #   "org.freedesktop.impl.portal.ScreenCast" = lib.mkForce ["luminous" "wlr"];
          #   "org.freedesktop.impl.portal.Screenshot" = lib.mkForce ["luminous" "wlr"];
          # };
          niri.default = ["gnome" "gtk"];
          sway.default = ["wlr" "gtk"];
        };
      };

      # Ensure AT-SPI accessibility bus starts before xdg-desktop-portal-gtk so GTK connects instantly
      # without timing out or freezing the desktop during login, preserving full screen reader/zoom support.
      systemd.user.services.xdg-desktop-portal-gtk = {
        after = ["at-spi-dbus-bus.service"];
        wants = ["at-spi-dbus-bus.service"];
        serviceConfig = {
          TimeoutStartSec = "60s";
        };
      };

      systemd.user.services.xdg-desktop-portal = {
        serviceConfig = {
          TimeoutStartSec = "60s";
        };
      };

      systemd.user.services.at-spi-dbus-bus = {
        wantedBy = ["graphical-session.target"];
        serviceConfig = {
          ExecStart = [
            "" # Clear default ExecStart
            "${pkgs.at-spi2-core}/libexec/at-spi-bus-launcher --launch-immediately"
          ];
        };
      };
    };

    # homeModules.nonDroid.xdg-portal = { ... }: {
    #   xdg.configFile."xdg-desktop-portal-luminous/config.toml".text = ''
    #     color_scheme = "${self.personas.ksv.theme_polarity}"
    #     screenshot_permission_check = false
    #   '';
    # };
  };
}
