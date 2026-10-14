{self, ...}: {
  flake.homeModules.common.jujutsu = {pkgs-unstable, ...}: {
    programs.jujutsu = {
      enable = true;
      package = pkgs-unstable.jujutsu;
      settings = {
        user = {
          name = self.personas.ksv.gitUsername;
          email = self.personas.ksv.gitEmail;
        };
        ui.default-command = "log";
        snapshot.max-new-file-size = "30MiB";
      };
    };
  };
}
