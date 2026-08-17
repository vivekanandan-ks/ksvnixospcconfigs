{
  lib,
  config,
  self,
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
        (
          {config, ...}:
            withSystem config.nixpkgs.hostPlatform.system (perSys: {
              _module.args =
                (builtins.removeAttrs perSys ["pkgs"])
                // {
                  inherit self inputs;
                  username = "ksvnixospc";
                };
            })
        )
      ];

    myIsDroidModule = option: [
      (_: {_module.args.isDroid = option;})
    ];
  };
}
