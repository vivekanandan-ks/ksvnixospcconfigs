_: {
  flake.hardwareModules.deejunixospc.base = {lib, ...}: {
    fileSystems."/" = {
      device = "/dev/disk/by-uuid/1da28acd-f352-4c3f-a9fa-15360c2bfa35";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/CE1C-432E";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };

    swapDevices = [
      {device = "/dev/disk/by-uuid/1ecdd4a4-53d2-4493-9326-4d17c336ac55";}
    ];

    # networking.interfaces.enp2s0.useDHCP = lib.mkDefault true;
    # networking.interfaces.wlp3s0.useDHCP = lib.mkDefault true;

    # Realtek RTL8821AE PCIe Wi-Fi stability fix (prevents disconnects/freezes under high CPU load)
    boot.extraModprobeConfig = ''
      options rtl8821ae aspm=0 fwlps=0 ips=0 msi=1
    '';
  };
}
