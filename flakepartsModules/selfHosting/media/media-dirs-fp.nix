{
  flake.nixosModules.selfHosting = {
    lib,
    pkgs,
    username,
    ...
  }: {
    # 1. Automatically ensure all media and torrent directories exist on boot with proper user:media permissions
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
      [
        "Z /data 0775 ${username} media -"
        "a+ /data - - - - d:u::rwx,d:g::rwx,d:m::rwx,d:u:${username}:rwx,d:g:media:rwx"
      ]
      ++ map (dir: "d ${dir} 0775 ${username} media -") mediaDirs;

    # 2. Harden nixflix-setup-dirs so transient warnings or path checks don't block boot
    systemd.services.nixflix-setup-dirs = {
      serviceConfig.ExecStart = lib.mkForce "-${pkgs.systemd}/bin/systemd-tmpfiles --create";
    };
  };
}
