{...}: {
  flake.homeModules.common.devenv = {pkgs-unstable, ...}: {
    programs.devenv = {
      enable = true;
      package = pkgs-unstable.devenv;
      enableNushellIntegration = false;
      enableFishIntegration = false;
      enableBashIntegration = false;
    };
  };
}
