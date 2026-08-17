{
  lib,
  config,
  self,
  inputs,
  withSystem,
  ...
}: {
  options.myCommonNixosModules = lib.mkOption {
    type = lib.types.unspecified;
  };
  options.myIsDroidModule = lib.mkOption {
    type = lib.types.unspecified;
  };

  config = {
    myCommonNixosModules = system:
      (builtins.attrValues config.flake.nixosModules)
      ++ [
        (withSystem system ({globalModuleArgs, ...}: {
          _module.args =
            globalModuleArgs
            // {
              inherit globalModuleArgs self inputs;
              username = "ksvnixospc";
            };
        }))
      ];

    myIsDroidModule = option: [
      (_: {_module.args.isDroid = option;})
    ];
  };
}
