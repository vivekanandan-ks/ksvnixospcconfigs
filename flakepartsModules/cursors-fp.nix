_: {
  flake = {
    homeModules.nonDroid.cursors = {
      config,
      pkgs-unstable,
      ...
    }: {
      # Stylix global cursor settings
      stylix.cursor = {
        package = pkgs-unstable.bibata-cursors-translucent;
        name = "Bibata_Ghost"; # FIXED: Using underscore instead of space
        size = 36;
      };

      # Hyprland specific cursor setup
      wayland.windowManager.hyprland = {
        settings = {
          # Ensure Hyprland internal compositor uses the cursor and size properly
          # This fixes the cursor defaulting to the Hyprland logo and not shape-shifting
          env = [
            "XCURSOR_THEME,${config.stylix.cursor.name}"
            "XCURSOR_SIZE,${toString config.stylix.cursor.size}"
            "HYPRCURSOR_THEME,${config.stylix.cursor.name}"
            "HYPRCURSOR_SIZE,${toString config.stylix.cursor.size}"
          ];

          # Force Hyprland to set the cursor immediately on startup
          exec-once = [
            "hyprctl setcursor ${config.stylix.cursor.name} ${toString config.stylix.cursor.size}"
          ];
        };
      };
    };
  };
}
