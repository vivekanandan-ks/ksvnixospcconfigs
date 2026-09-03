_: {
  flake.hardwareModules.akashnixospc.base = {...}: {
    imports = [../../../hosts/akashnixospc/hardware-configuration-akashnixospc.nix];
  };
}
