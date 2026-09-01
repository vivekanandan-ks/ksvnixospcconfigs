{
  config,
  inputs,
  lib,
  ...
}: let
  facterFile = ./deejunixospc-facter.json;
  inherit ((builtins.fromJSON (builtins.readFile facterFile))) system;
in {
  flake.nixosConfigurations.deejunixospc = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    modules =
      [
        config.flake.hardwareModules.deejunixospc
        {
          hardware.facter.reportPath = facterFile;
        }

        inputs.home-manager.nixosModules.home-manager
        {
          networking.hostName = "deejunixospc";
          # services.displayManager.defaultSession = lib.mkForce "plasma";
          # services.displayManager.ly.enable = lib.mkForce false;
          # services.displayManager.sddm.enable = lib.mkForce true;
        }
      ]
      /*
        ++ (lib.optionals (inputs ? disko) [
        inputs.disko.nixosModules.disko
        {
          disko.devices = config.flake.diskoConfigurations.deejunixospc.disko.devices;
        }
      ])
      */
      ++ (config.myCommonNixosModules system);
  };
  flake.deejunixospc = config.flake.nixosConfigurations.deejunixospc;
}
