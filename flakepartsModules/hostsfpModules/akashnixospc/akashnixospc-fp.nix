{
  config,
  inputs,
  ...
}: let
  system = "x86_64-linux";
in {
  flake.nixosConfigurations.akashnixospc = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    modules =
      (builtins.attrValues (config.flake.hardwareModules.akashnixospc or {}))
      ++ [
        inputs.home-manager.nixosModules.home-manager
        {networking.hostName = "akashnixospc";}
      ]
      ++ (config.myCommonNixosModules system);
  };
  flake.akashnixospc = config.flake.nixosConfigurations.akashnixospc;
}
