{
  config,
  inputs,
  lib,
  ...
}: {
  flake.nixosConfigurations.deejunixospc = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules =
      [
        config.flake.hardwareModules.deejunixospc
        inputs.home-manager.nixosModules.home-manager
        {
          networking.hostName = "deejunixospc";
          services.displayManager.defaultSession = lib.mkForce "plasma";
          services.displayManager.ly.enable = lib.mkForce false;
          services.displayManager.sddm.enable = lib.mkForce true;
        }
      ]
      ++ (config.myIsDroidModule false) ++ config.myCommonNixosModules;
  };
  flake.deejunixospc = config.flake.nixosConfigurations.deejunixospc;
}
