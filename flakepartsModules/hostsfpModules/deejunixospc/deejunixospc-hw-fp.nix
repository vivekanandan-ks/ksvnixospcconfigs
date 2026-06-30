{ ... }: {
  flake.hardwareModules.deejunixospc = { ... }: {
    imports = [ ../../../hosts/deejunixospc/hardware-configuration-deejunixospc.nix ];
  };
}
