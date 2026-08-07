{
  inputs,
  ...
}: {
  flake = {
    homeModules.common.fastfetch = {
      pkgs,
      self,
      ...
    }: {
      programs.fastfetch = {
        enable = true;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.ksvFastfetch;
      };
    };
  };

  perSystem = {pkgs-unstable, ...}: {
    packages.ksvFastfetch = inputs.wrapper-modules.wrappers.fastfetch.wrap {
      pkgs = pkgs-unstable;
      package = pkgs-unstable.fastfetch;
      settings = builtins.fromJSON (
        builtins.readFile ./fastfetch-settings.json
      );
    };
  };
}
