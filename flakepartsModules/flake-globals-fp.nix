{ lib, inputs, ... }: {
  options.flake.homeModules = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.unspecified;
    default = {};
  };

  options.flake.hardwareModules = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.unspecified;
    default = {};
  };

  config = {
    systems = [
      "x86_64-linux"
      "aarch64-linux" # Added for Nix-on-Droid
    ];

    perSystem = {
      config,
      self',
      inputs',
      pkgs,
      system,
      ...
    }: {
      # Per-system attributes can be defined here. The self' and inputs'
      # module parameters provide easy access to attributes of the same
      # system.

      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        nvidia.acceptLicense = true;
      };

      _module.args.pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
        nvidia.acceptLicense = true;
      };
    };
  };
}
