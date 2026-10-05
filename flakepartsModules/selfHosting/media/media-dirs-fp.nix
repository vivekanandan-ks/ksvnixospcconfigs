{
  flake.nixosModules.selfHosting = {
    username,
    ...
  }: {
    # Automatically ensure all media and torrent directories exist on boot with proper permissions
    systemd.tmpfiles.rules = let
      mediaDirs = [
        "/data/media"
        "/data/media/movies"
        "/data/media/shows"
        "/data/media/anime"
        "/data/media/music"
        "/data/media/manga"
        "/data/torrents"
        "/data/torrents/incomplete"
        "/data/torrents/complete"
      ];
    in
      map (dir: "d ${dir} 0775 ${username} media -") mediaDirs;
  };
}
