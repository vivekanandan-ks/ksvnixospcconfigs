{
  config,
  inputs,
  withSystem,
  ...
}: let
  system = "aarch64-linux";
in {
  flake-file.inputs = {
    nix-on-droid.url = "github:nix-community/nix-on-droid";
    #nix-on-droid.url = "github:nix-community/nix-on-droid/release-24.05";
  };

  flake.nixOnDroidConfigurations.default = withSystem system ({
    globalModuleArgs,
    pkgs-unstable,
    ...
  }:
    inputs.nix-on-droid.lib.nixOnDroidConfiguration {
      pkgs = pkgs-unstable.appendOverlays [
        inputs.nix-on-droid.overlays.default
      ];
      extraSpecialArgs =
        globalModuleArgs
        // {
          inherit globalModuleArgs;
          username = "nix-on-droid";
        };
      modules = builtins.attrValues config.flake.nixOnDroidModules;
      home-manager-path = inputs.home-manager;
    });
}
