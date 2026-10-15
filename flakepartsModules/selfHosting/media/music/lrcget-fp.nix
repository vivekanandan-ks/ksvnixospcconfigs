{ inputs, lib, ... }: {
  flake.nixosModules.selfHosting = { pkgs, ... }: lib.mkIf (inputs ? nixflix) (
    let
      musicDir = "/data/media/music";

      syncScript = pkgs.writeShellScriptBin "sync-lyrics" ''
        ${pkgs.findutils}/bin/find "${musicDir}" -type f \( -name "*.mp3" -o -name "*.flac" -o -name "*.m4a" -o -name "*.ogg" -o -name "*.opus" \) | while read -r f; do
          lrc="''${f%.*}.lrc"
          if [ ! -f "$lrc" ]; then
            # Clean filename by stripping bracketed video IDs like [PB4VaN_qV3Q]
            query=$(basename "''${f%.*}" | ${pkgs.gnused}/bin/sed -E 's/ \[[^]]+\]//g; s/\[[^]]+\]//g')
            echo "Downloading lyrics for: $query ($(basename "$f"))"
            ${pkgs.python3Packages.syncedlyrics}/bin/syncedlyrics "$query" -p lrclib musixmatch -o "$lrc" || true
            sleep 1
          fi
        done
      '';
    in
    {
      # 1. Kernel-level filesystem watch (0 RAM while idle)
      systemd.paths.lyrics-sync = {
        description = "Watch /data/media/music for downloads";
        wantedBy = [ "multi-user.target" ];
        pathConfig = {
          PathChanged = [ musicDir ];
        };
      };

      # 2. Oneshot sync job triggered automatically when slskd finishes writing files
      systemd.services.lyrics-sync = {
        description = "Fetch Missing Lyrics";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];

        # Prevent nixos-rebuild/ksvnh from blocking if lyrics are actively downloading
        stopIfChanged = false;
        restartIfChanged = false;

        serviceConfig = {
          Type = "oneshot";
          User = "slskd";
          Group = "media";
          Environment = [
            "HOME=/tmp"
            "XDG_CACHE_HOME=/tmp"
          ];
          ExecStart = "${syncScript}/bin/sync-lyrics";
          ProtectSystem = "full";
          ReadWritePaths = [ musicDir "/tmp" ];
        };
      };
    }
  );
}
