_: {
  flake = {
    # System-level Hyprland portal integration
    nixosModules.hyprland-misc = {pkgs-unstable, ...}: {
      xdg.portal = {
        extraPortals = [
          pkgs-unstable.xdg-desktop-portal-hyprland
        ];
        config = {
          hyprland.default = ["hyprland" "gtk"];
        };
      };
    };

    # User-level Hyprland integrations (cursors, screenshots, systemd targets)
    homeModules.nonDroid.hyprland-misc = {
      config,
      lib,
      ...
    }: let
      saveDir = "${config.xdg.userDirs.pictures}/Screenshots";
    in {
      wayland.windowManager.hyprland.settings = {
        # Cursor environment variables & runtime initialization
        env = [
          "XCURSOR_THEME,${config.stylix.cursor.name}"
          "XCURSOR_SIZE,${toString config.stylix.cursor.size}"
          "HYPRCURSOR_THEME,${config.stylix.cursor.name}"
          "HYPRCURSOR_SIZE,${toString config.stylix.cursor.size}"
        ];

        exec-once = [
          "hyprctl setcursor ${config.stylix.cursor.name} ${toString config.stylix.cursor.size}"
        ];

        # Screenshot tool keybindings
        bind = lib.mkAfter [
          ", Print, exec, flameshot gui"
          "SUPER, Print, exec, flameshot full -c -p ${saveDir}"
        ];
      };

      # Hyprland session target dependencies for Flameshot
      systemd.user.services.flameshot = lib.mkIf config.wayland.windowManager.hyprland.enable {
        Unit = {
          After = ["hyprland-session.target"];
          PartOf = ["hyprland-session.target"];
        };
        Install = {
          WantedBy = ["hyprland-session.target"];
        };
      };
    };
  };
}
