{
  config,
  inputs,
  withSystem,
  ...
}: {
  flake-file.inputs = {
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid";
      #url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  flake.nixOnDroidConfigurations.default = withSystem "aarch64-linux" ({
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
