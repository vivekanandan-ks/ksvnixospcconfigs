{
  self,
  inputs,
  lib,
  ...
}: {
  # 1. Declarative Package exposed across all flake systems
  perSystem = {pkgs, ...}: {
    packages.lrcget-cli = pkgs.rustPlatform.buildRustPackage {
      pname = "lrcget-cli";
      version = "1.0.0-beta";

      src = pkgs.fetchFromGitHub {
        owner = "diego-ninja";
        repo = "lrcget-cli";
        rev = "v1.0.0-beta";
        hash = "sha256-UDu1FlBKKOT4sK9pKcviwc88ArMpdvBC10hpDz4NIqA=";
      };

      cargoHash = "sha256-TCzjPEnTeB01yGcc1c+y1+BXcVkJfPyJLIkJnV6FVnY=";

      # Disable broken upstream unit tests from the beta release
      doCheck = false;
    };
  };

  # 2. Self-Hosting NixOS Service consuming the flake package
  flake.nixosModules.selfHosting = {pkgs, ...}:
    lib.mkIf (inputs ? nixflix) (
      let
        musicDir = "/data/media/music";
        lrcgetPkg = self.packages.${pkgs.stdenv.hostPlatform.system}.lrcget-cli;
      in {
        systemd.services.lrcget = {
          description = "LRCGET CLI Lyrics Watcher Daemon";
          after = [
            "network-online.target"
            "slskd.service"
          ];
          wants = ["network-online.target"];
          wantedBy = ["multi-user.target"];

          serviceConfig = {
            Type = "simple";
            User = "slskd";
            Group = "media";

            # Persistent SQLite database in /var/lib/lrcget (avoids repeat scans)
            StateDirectory = "lrcget";
            Environment = [
              "HOME=/var/lib/lrcget"
              "XDG_DATA_HOME=/var/lib/lrcget/data"
              "XDG_CACHE_HOME=/var/lib/lrcget/cache"
              "XDG_CONFIG_HOME=/var/lib/lrcget/config"
            ];

            ExecStart = "${lrcgetPkg}/bin/lrcget watch ${musicDir} --initial-scan --fuzzy-search";

            Restart = "on-failure";
            RestartSec = "10s";

            ProtectSystem = "full";
            ReadWritePaths = [
              musicDir
              "/var/lib/lrcget"
            ];
          };
        };
      }
    );
}
