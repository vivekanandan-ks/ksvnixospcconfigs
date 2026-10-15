{ inputs, lib, ... }: {
  flake.nixosModules.selfHosting = { pkgs, ... }: lib.mkIf (inputs ? nixflix) (
    let
      musicDir = "/data/media/music";

      syncScript = pkgs.writeShellScriptBin "sync-lyrics" ''
        ${pkgs.findutils}/bin/find "${musicDir}" -type f \( -name "*.mp3" -o -name "*.flac" -o -name "*.m4a" -o -name "*.ogg" \) | while read -r f; do
          lrc="''${f%.*}.lrc"
          if [ ! -f "$lrc" ]; then
            echo "Downloading lyrics for: $(basename "$f")"
            ${pkgs.python3Packages.syncedlyrics}/bin/syncedlyrics "$(basename "''${f%.*}")" -p lrclib musixmatch -o "$lrc" || true
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

        serviceConfig = {
          Type = "oneshot";
          User = "slskd";
          Group = "media";
          ExecStart = "${syncScript}/bin/sync-lyrics";
          ProtectSystem = "full";
          ReadWritePaths = [ musicDir ];
        };
      };
    }
  );
}
