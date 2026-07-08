{...}: {
  flake.hardwareModules.ksvnixospc = {...}: {
    imports = [../../../hosts/ksvnixospc/hardware-configuration-ksvnixospc.nix];
  };
}
