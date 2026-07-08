{...}: {
  flake.hardwareModules.ksv-nix-on-droid = {...}: {
    imports = [../../../hosts/ksv-nix-on-droid/ksv-nix-on-droid.nix];
  };
}
