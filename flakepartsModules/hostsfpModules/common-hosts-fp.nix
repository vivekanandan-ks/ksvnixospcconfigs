{
  lib,
  config,
  inputs,
  withSystem,
  ...
}: {
  options.myCommonNixosModules = lib.mkOption {
    type = lib.types.listOf lib.types.unspecified;
  };
  options.myIsDroidModule = lib.mkOption {
    type = lib.types.unspecified;
  };

  config = {
    myCommonNixosModules =
      (builtins.attrValues config.flake.nixosModules)
      ++ [
        (_: {
          _module.args.pkgs-unstable = withSystem "x86_64-linux" ({pkgs-unstable, ...}: pkgs-unstable);
          _module.args = {
            inherit inputs;
            username = "ksvnixospc";
            inherit (inputs) nix4vscode;
            system = "x86_64-linux";
            inherit (inputs) self;
          };
        })
      ];

    myIsDroidModule = option: [
      (_: {_module.args.isDroid = option;})
    ];
  };
}
