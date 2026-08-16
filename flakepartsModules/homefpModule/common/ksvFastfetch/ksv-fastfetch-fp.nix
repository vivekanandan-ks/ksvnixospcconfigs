{inputs, ...}: {
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

  perSystem = {
    pkgs,
    pkgs-unstable,
    ...
  }: {
    packages.ksvFastfetch = inputs.wrapper-modules.wrappers.fastfetch.wrap {
      inherit pkgs;
      package = pkgs-unstable.fastfetch;
      settings = builtins.fromJSON (
        builtins.readFile ./fastfetch-settings.json
      );
    };
  };
}
