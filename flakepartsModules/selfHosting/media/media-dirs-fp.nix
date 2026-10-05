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
        "/data/media/shows"
        "/data/media/anime"
        "/data/media/music"
        "/data/media/manga"
        "/data/torrents"
        "/data/torrents/incomplete"
        "/data/torrents/complete"
      ];
    in
      map (dir: "d ${dir} 0775 root media -") mediaDirs;

    # 2. Ensure /data base directory has correct root:media ownership before tmpfiles runs
    systemd.services.media-storage-permissions = {
      description = "Ensure /data base directory has correct root:media ownership";
      wantedBy = [ "multi-user.target" ];
      before = [ "nixflix-setup-dirs.service" ];
      unitConfig.ConditionPathExists = "/data";
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "fix-media-permissions" ''
          chown root:media /data || true
          chmod 775 /data || true
        '';
      };
    };

    # 3. Harden nixflix-setup-dirs so transient warnings or path checks don't block boot
    systemd.services.nixflix-setup-dirs = {
      after = [ "media-storage-permissions.service" ];
      serviceConfig.ExecStart = lib.mkForce (pkgs.writeShellScript "nixflix-setup-dirs-start" ''
        ${pkgs.systemd}/bin/systemd-tmpfiles --create || true
      '');
    };
  };
}
