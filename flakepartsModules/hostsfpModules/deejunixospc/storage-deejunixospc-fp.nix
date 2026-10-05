{
  flake.hostModules.deejunixospc.storage = {
    # 1. Statically mount the 200GBHDD2 partition on boot
    fileSystems."/mnt/storage/200GBHDD2" = {
      device = "/dev/disk/by-label/200GBHDD2";
      fsType = "ntfs3";
      options = [
        "nofail"
        "uid=1003"       # ksvnixospc user ID on deejunixospc
        "gid=169"        # media group ID (nixflix standard)
        "dmask=0002"     # 0775 permissions for directories (rwx for owner and media group)
        "fmask=0002"     # 0775 permissions for files
        "iocharset=utf8"
      ];
    };

    # 2. Bind mount the selfHost folder on 200GBHDD2 to the universal /data path
    fileSystems."/data" = {
      device = "/mnt/storage/200GBHDD2/selfHost";
      fsType = "none";
      options = [ "bind" "nofail" ];
      depends = [ "/mnt/storage/200GBHDD2" ];
    };
  };
}
