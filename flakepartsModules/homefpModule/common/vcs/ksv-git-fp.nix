{self, ...}: {
  flake.homeModules.common.git = {pkgs-unstable, ...}: {
    programs.git = {
      enable = true;
      package = pkgs-unstable.git;
      signing.format = null;
      settings = {
        user = {
          name = self.personas.ksv.gitUsername;
          email = self.personas.ksv.gitEmail;
        };
        init.defaultBranch = "main";
      };
    };
  };
}
