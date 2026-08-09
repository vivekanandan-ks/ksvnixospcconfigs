{
  config,
  inputs,
  lib,
  ...
}: {
  flake.nixosConfigurations.ksvnixospc = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules =
      [
        inputs.home-manager.nixosModules.home-manager
        {
          networking.hostName = "ksvnixospc";
          hardware.facter.reportPath = ./ksvnixospc-facter.json;
        }
      ]
      ++ (lib.optionals (inputs ? disko) [
        inputs.disko.nixosModules.disko
        {
          disko.devices = config.flake.diskoConfigurations.ksvnixospc.disko.devices;
        }
      ])
      ++ (config.myIsDroidModule false) ++ config.myCommonNixosModules;
  };
  flake.ksvnixospc = config.flake.nixosConfigurations.ksvnixospc;
}
