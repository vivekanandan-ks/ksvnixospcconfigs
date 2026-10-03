{
  flake.hostModules.ksvnixospc.storage = {
    # Bind mount the selfHost folder on the 237GB partition to the universal /data path
    fileSystems."/data" = {
      device = "/mnt/storage/237GB/selfHost";
      fsType = "none";
      options = [ "bind" "nofail" ];
      depends = [ "/mnt/storage/237GB" ];
    };
  };
}
