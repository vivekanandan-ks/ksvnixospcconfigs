{ inputs, lib, ... }: {
  flake.nixosModules.selfHosting = { pkgs, ... }: lib.mkIf (inputs ? nixflix) (
    let
      musicDir = "/data/media/music";

      pythonWithMutagen = pkgs.python3.withPackages (ps: [ ps.mutagen ]);

      syncScript = pkgs.writeShellScriptBin "sync-lyrics" ''
        ${pkgs.findutils}/bin/find "${musicDir}" -type f \( -name "*.mp3" -o -name "*.flac" -o -name "*.m4a" -o -name "*.ogg" -o -name "*.opus" \) | while read -r f; do
          lrc="''${f%.*}.lrc"
          if [ ! -f "$lrc" ]; then
            # 1. Try reading Artist and Title directly from embedded metadata tags
            tag_query=$(${pythonWithMutagen}/bin/python3 -c '
import sys, mutagen
try:
    audio = mutagen.File(sys.argv[1], easy=True)
    if audio:
        artist = audio.get("artist", [""])[0].split(",")[0].strip()
        title = audio.get("title", [""])[0].strip()
        if artist and title:
            print(f"{artist} - {title}")
        elif title:
            print(title)
except:
    pass
' "$f" 2>/dev/null || true)

            # 2. Fall back to cleaned filename if tags are missing
            if [ -n "$tag_query" ]; then
              query="$tag_query"
            else
              query=$(basename "''${f%.*}" | ${pkgs.gnused}/bin/sed -E 's/ \[[^]]+\]//g; s/\[[^]]+\]//g')
            fi

            echo "Downloading lyrics for: $query ($(basename "$f"))"
            ${pkgs.python3Packages.syncedlyrics}/bin/syncedlyrics "$query" -o "$lrc" || true
            sleep 2
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
