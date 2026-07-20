{
  config,
  inputs,
  ...
}: {
  flake.nixosConfigurations.akashnixospc = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules =
      [
        config.flake.hardwareModules.akashnixospc
        inputs.home-manager.nixosModules.home-manager
        {networking.hostName = "akashnixospc";}
      ]
      ++ (config.myIsDroidModule false) ++ config.myCommonNixosModules;
  };
  flake.akashnixospc = config.flake.nixosConfigurations.akashnixospc;
}
