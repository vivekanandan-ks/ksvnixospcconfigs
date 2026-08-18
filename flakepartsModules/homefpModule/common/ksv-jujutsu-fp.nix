{
  inputs,
  self,
  ...
}: {
  flake = {
    homeModules.common.jujutsu = {pkgs, ...}: {
      programs.jujutsu = {
        enable = true;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.ksvJujutsu;
      };
    };
  };

  perSystem = {
    pkgs,
    pkgs-unstable,
    ...
  }: {
    packages.ksvJujutsu = inputs.wrapper-modules.wrappers.jujutsu.wrap {
      inherit pkgs;
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
