{ lib, config, inputs, withSystem, ... }: {
  options.myCommonNixosModules = lib.mkOption {
    type = lib.types.listOf lib.types.unspecified;
  };
  options.myIsDroidModule = lib.mkOption {
    type = lib.types.unspecified;
  };

  config = {
    myCommonNixosModules = (builtins.attrValues config.flake.nixosModules) ++ [
      inputs.determinate.nixosModules.default
      ({ ... }: {
        _module.args.pkgs-unstable = withSystem "x86_64-linux" ({ pkgs-unstable, ... }: pkgs-unstable);
        _module.args = {
          inputs = inputs;
          username = "ksvnixospc";
          nix4vscode = inputs.nix4vscode;
          system = "x86_64-linux";
          self = inputs.self;
        };
      })
    ];

    myIsDroidModule = option: [
      ({ ... }: { _module.args.isDroid = option; })
    ];
  };
}
