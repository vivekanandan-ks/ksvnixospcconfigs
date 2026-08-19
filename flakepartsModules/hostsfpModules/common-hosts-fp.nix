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

  config = {
    myCommonNixosModules = system:
      (builtins.attrValues config.flake.nixosModules)
      ++ [
        (withSystem system ({globalModuleArgs, ...}: {
          _module.args =
            globalModuleArgs
            // {
              inherit globalModuleArgs self inputs;
              username = self.personas.ksv.username;
            };
        }))
      ];
  };
}
