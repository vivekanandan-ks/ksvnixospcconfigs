{
  config,
  inputs,
  self,
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
      /*
      pkgs = import inputs.nixpkgs {
        system = "aarch64-linux";
        config.allowUnfree = true;
        overlays = [inputs.nix-on-droid.overlays.default];
      };
      */
      pkgs = pkgs-unstable.appendOverlays [
        inputs.nix-on-droid.overlays.default
      ];
      extraSpecialArgs =
        globalModuleArgs
        // {
          inherit globalModuleArgs inputs self;
          username = "nix-on-droid";
          isDroid = true;
        };
      modules =
        [
          config.flake.hardwareModules.ksv-nix-on-droid
          {
            _module.args =
              globalModuleArgs
              // {
                inherit globalModuleArgs inputs self;
                username = "nix-on-droid";
              };
          }
        ]
        ++ (config.myIsDroidModule true);
      home-manager-path = inputs.home-manager;
    });
}
