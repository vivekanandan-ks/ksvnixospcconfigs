{
  config,
  inputs,
  ...
}: {
  flake.nixosConfigurations.ksvnixospc = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules =
      [
        #config.flake.hardwareModules.ksvnixospc
        {
          networking.hostName = "ksvnixospc";
          hardware.facter.reportPath = ./ksvnixospc-facter.json;
        }
        inputs.home-manager.nixosModules.home-manager
      ]
      ++ (config.myIsDroidModule false) ++ config.myCommonNixosModules;
  };
  flake.ksvnixospc = config.flake.nixosConfigurations.ksvnixospc;
}
