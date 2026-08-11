_: {
  flake.homeModules.nonDroid.satty = {
    config,
    pkgs-unstable,
    ...
  }: {
    programs.satty = {
      enable = true;
      package = pkgs-unstable.satty;
      settings = {
        general = {
          output-filename = "${config.xdg.userDirs.pictures}/sattyScreenshots/satty-%Y-%m-%d_%H:%M:%S.png";
          save-after-copy = true;
        };
      };
    };
  };
}
