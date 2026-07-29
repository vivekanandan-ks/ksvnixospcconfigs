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

  flake.nixOnDroidConfigurations.default = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
    pkgs = import inputs.nixpkgs {
      system = "aarch64-linux";
      config.allowUnfree = true;
      overlays = [inputs.nix-on-droid.overlays.default];
    };
    modules =
      [
        config.flake.hardwareModules.ksv-nix-on-droid
        ({pkgs, ...}: {
          _module.args = {
            inputs = inputs;
            system = "aarch64-linux";
            pkgs-unstable = withSystem "aarch64-linux" ({pkgs-unstable, ...}: pkgs-unstable);
            self = inputs.self;
            username = "nix-on-droid";
          };
        })
      ]
      ++ (config.myIsDroidModule true);
    home-manager-path = inputs.home-manager.outPath;
  };
}
