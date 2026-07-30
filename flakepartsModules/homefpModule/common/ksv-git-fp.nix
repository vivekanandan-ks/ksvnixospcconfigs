{
  self,
  inputs,
  ...
}: {
  flake = {
    homeModules.common.git = {
      pkgs,
      self,
      ...
    }: {
      programs.git = {
        enable = true;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.ksvGit;
        signing.format = null;
      };
    };
  };

  perSystem = {pkgs-unstable, ...}: {
    packages.ksvGit = inputs.wrapper-modules.wrappers.git.wrap {
      pkgs = pkgs-unstable;
      package = pkgs-unstable.git;
      settings = {
        user = {
          name = "vivekanandan-ks";
          email = "ksvdevksv@gmail.com";
        };
        init = {
          defaultBranch = "main";
        };
      };
    };
  };
}
