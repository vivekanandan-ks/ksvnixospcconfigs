{
  flake.nixosModules.selfHosting = {
    lib,
    pkgs,
    ...
  }: {
    # 1. Automatically ensure all media and torrent directories exist on boot with proper root:media permissions
    systemd.tmpfiles.rules = let
      mediaDirs = [
        "/data/media"
        "/data/media/movies"
        "/data/media/tv"
        "/data/media/anime"
        "/data/media/music"
        "/data/media/manga"
        "/data/torrents"
        "/data/torrents/incomplete"
        "/data/torrents/complete"
      ];
    in
      [ "z /data 0775 root media -" ]
      ++ map (dir: "d ${dir} 0775 root media -") mediaDirs;

    # 2. Harden nixflix-setup-dirs so transient warnings or path checks don't block boot
    systemd.services.nixflix-setup-dirs = {
      serviceConfig.ExecStart = lib.mkForce "-${pkgs.systemd}/bin/systemd-tmpfiles --create";
    };
  };
}
