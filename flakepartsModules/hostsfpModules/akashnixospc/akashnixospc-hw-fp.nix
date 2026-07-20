{...}: {
  flake.hardwareModules.akashnixospc = {...}: {
    imports = [../../../hosts/akashnixospc/hardware-configuration-akashnixospc.nix];
  };
}
