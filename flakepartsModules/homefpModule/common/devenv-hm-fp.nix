_: {
  flake-file.nixConfig = {
    extra-substituters = ["https://devenv.cachix.org"];
    extra-trusted-public-keys = ["devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="];
  };

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
