{
  config,
  inputs,
  lib,
  ...
}: let
  facterFile = ./ksvnixospc-facter.json;
  inherit ((builtins.fromJSON (builtins.readFile facterFile))) system;
in {
  flake.nixosConfigurations.ksvnixospc = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    modules =
      [
        inputs.home-manager.nixosModules.home-manager
        {
          networking.hostName = "ksvnixospc";
          hardware.facter.reportPath = facterFile;
        }
      ]
      ++ (lib.optionals (inputs ? disko) [
        inputs.disko.nixosModules.disko
        {
          disko.devices = config.flake.diskoConfigurations.ksvnixospc.disko.devices;
        }
      ])
      ++ (config.myCommonNixosModules system);
  };
  flake.ksvnixospc = config.flake.nixosConfigurations.ksvnixospc;
}
