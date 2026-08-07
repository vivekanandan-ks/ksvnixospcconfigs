{inputs, ...}: {
  flake = {
    homeModules.common.jujutsu = {
      pkgs,
      self,
      ...
    }: {
      programs.jujutsu = {
        enable = true;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.ksvJujutsu;
      };
    };
  };

  perSystem = {pkgs-unstable, ...}: {
    packages.ksvJujutsu = inputs.wrapper-modules.wrappers.jujutsu.wrap {
      pkgs = pkgs-unstable;
      package = pkgs-unstable.jujutsu;
      settings = {
        user = {
          email = "ksvdevksv@gmail.com";
          name = "vivekanandan-ks";
        };
        ui.default-command = "log";
        snapshot.max-new-file-size = "30MiB";
      };
    };
  };
}
