{
  inputs,
  self,
  ...
}: {
  flake = {
    homeModules.common.git = {pkgs, ...}: {
      programs.git = {
        enable = true;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.ksvGit;
        signing.format = null;
      };
    };
  };

  perSystem = {
    pkgs,
    pkgs-unstable,
    ...
  }: {
    packages.ksvGit = inputs.wrapper-modules.wrappers.git.wrap {
      inherit pkgs;
      package = pkgs-unstable.git;
      settings = {
        user = {
          name = self.personas.ksv.gitUsername;
          email = self.personas.ksv.gitEmail;
        };
        init = {
          defaultBranch = "main";
        };
      };
    };
  };
}
