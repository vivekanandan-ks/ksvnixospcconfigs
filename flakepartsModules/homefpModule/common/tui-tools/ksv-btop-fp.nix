{
  inputs,
  self,
  ...
}: {
  flake = {
    homeModules.common.btop = {pkgs, ...}: {
      programs.btop = {
        enable = true;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.ksvBtop;
      };
    };
  };

  perSystem = {
    pkgs,
    pkgs-unstable,
    ...
  }: {
    packages.ksvBtop = inputs.wrapper-modules.wrappers.btop.wrap {
      inherit pkgs;
      package = pkgs-unstable.btop;
      settings = {};
    };
  };
}
