{
  self,
  inputs,
  ...
}: {
  perSystem = {pkgs-unstable, ...}: {
    packages.ksvBtop = inputs.wrapper-modules.wrappers.btop.wrap {
      pkgs = pkgs-unstable;
      package = pkgs-unstable.btop;
      settings = { };
    };
  };

  flake = {
    homeModules.common.btop = { pkgs, self, ... }: {
      programs.btop = {
        enable = true;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.ksvBtop;
      };
    };
  };
}
