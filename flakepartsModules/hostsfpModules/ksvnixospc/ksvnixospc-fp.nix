{ config, inputs, ... }: {
  flake.nixosConfigurations.ksvnixospc = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      config.flake.hardwareModules.ksvnixospc
      inputs.home-manager.nixosModules.home-manager
      { networking.hostName = "ksvnixospc"; }
    ] ++ (config.myIsDroidModule false) ++ config.myCommonNixosModules;
  };
}
