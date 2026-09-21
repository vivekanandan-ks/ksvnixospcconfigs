_: {
  flake = {
    nixosModules.xdg-portal = {
      lib,
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
    };

    # homeModules.nonDroid.xdg-portal = { ... }: {
    #   xdg.configFile."xdg-desktop-portal-luminous/config.toml".text = ''
    #     color_scheme = "${self.personas.ksv.theme_polarity}"
    #     screenshot_permission_check = false
    #   '';
    # };
  };
}
