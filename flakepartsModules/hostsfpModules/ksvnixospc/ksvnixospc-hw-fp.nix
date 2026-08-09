_: {
  flake.hardwareModules.ksvnixospc = _: {
    # imports = [../../../hosts/ksvnixospc/hardware-configuration-ksvnixospc.nix];

    # NixOS Facter automated hardware detection & kernel modules
    hardware.facter.reportPath = ./ksvnixospc-facter.json;

    # Dynamic extraction of fileSystems from hardware configuration (Method 2):
    # (Requires updating module arguments to `{ config, lib, modulesPath, ... }:`)
    /*
    inherit
    ((import ../../../hosts/ksvnixospc/hardware-configuration-ksvnixospc.nix {
      inherit config lib modulesPath;
    }))
    fileSystems
    ;
    */

    # File system mounts (exact UUIDs from hardware-configuration)

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/b34558df-d86b-4c9f-91de-a6ae87bdf76d";
      # device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/3E19-4587";
      # device = "/dev/disk/by-label/boot";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };
  };
}
