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
          _module.args.pkgs-mv-fast-tip = withSystem "x86_64-linux" ({pkgs-mv-fast-tip, ...}: pkgs-mv-fast-tip);
          _module.args.pkgs-stable = withSystem "x86_64-linux" ({pkgs-stable, ...}: pkgs-stable);
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
