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
    };
  };
}
