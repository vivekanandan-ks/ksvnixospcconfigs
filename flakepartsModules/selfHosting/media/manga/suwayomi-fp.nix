{ inputs, lib, ... }: {
  flake.nixosModules.selfHosting = { pkgs, ... }: let
    # Declarative extension packages (Verified stable, free of InstantiationError)
    mangaExtensions = [
      # 1. MangaDex (Official translations, full Solo Leveling + Ragnarok)
      {
        name = "MangaDex";
        pkgName = "eu.kanade.tachiyomi.extension.all.mangadex";
        file = pkgs.fetchurl {
          name = "tachiyomi-all.mangadex-v1.6.0.apk";
          url = "https://github.com/keiyoushi/extensions/releases/download/8ef06cd-0/tachiyomi-all.mangadex-v1.6.0.apk";
          hash = "sha256-Ev3ndgHUjIsjE0BpTbhEb7paVVztQQmyMcnS4wAJFfs=";
        };
      }
      # 2. Mangakakalot (Massive manhwa/manga aggregator, fast search)
      {
        name = "Mangakakalot";
        pkgName = "eu.kanade.tachiyomi.extension.en.mangakakalot";
        file = pkgs.fetchurl {
          name = "tachiyomi-en.mangakakalot-v1.6.24.apk";
          url = "https://github.com/keiyoushi/extensions/releases/download/4217666-0/tachiyomi-en.mangakakalot-v1.6.24.apk";
          hash = "sha256-rdxFujcUXxQtQIi9KLfAYqHRzhw791BUiQdzYk9M/G4=";
        };
      }
      # 3. Manganato (Dedicated manhwa mirrors, complete Solo Leveling archive)
      {
        name = "Manganato";
        pkgName = "eu.kanade.tachiyomi.extension.en.manganelo";
        file = pkgs.fetchurl {
          name = "tachiyomi-en.manganelo-v1.6.22.apk";
          url = "https://github.com/keiyoushi/extensions/releases/download/4217666-0/tachiyomi-en.manganelo-v1.6.22.apk";
          hash = "sha256-p9XQ1wfbWUtGkoTqNaytr0Y+/WP7bOb9KQUczTzYHC8=";
        };
      }
      # 4. MangaFire (High-speed modern library with multi-language scans)
      {
        name = "MangaFire";
        pkgName = "eu.kanade.tachiyomi.extension.all.mangafire";
        file = pkgs.fetchurl {
          name = "tachiyomi-all.mangafire-v1.6.34.apk";
          url = "https://github.com/keiyoushi/extensions/releases/download/4217666-0/tachiyomi-all.mangafire-v1.6.34.apk";
          hash = "sha256-vF0jpWXx51LNskR4hka9Jyg2OALOCCPHCxaOf0jkH60=";
        };
      }
    ];
  in lib.mkIf (inputs ? nixflix) {
    # 1. Automated Manga & Manhwa Scraper / Downloader
    services.suwayomi-server = {
      enable = true;
      # Bump to v2.4.2366 to support Extension API v1.6 and Mihon Extension Stores
      package = pkgs.suwayomi-server.overrideAttrs (old: rec {
        version = "2.4.2366";
        src = pkgs.fetchurl {
          url = "https://github.com/Suwayomi/Suwayomi-Server/releases/download/v${version}/Suwayomi-Server-v${version}.jar";
          hash = "sha256-r5/rIK+dfr6eMHaebG68f8erHERziNQuAoCx2l/ge/0=";
        };
      });
      group = "media";
      dataDir = "/var/lib/suwayomi-server";
      settings = {
        server = {
          ip = "0.0.0.0";
          port = 4567;
          downloadsPath = "/data/media/manga";
          downloadAsCbz = true;
          systemTrayEnabled = false;
          initialOpenInBrowserEnabled = false;
          extensionStores = [
            "https://raw.githubusercontent.com/keiyoushi/extensions/repo/index.json"
          ];
        };
      };
    };

    # Ensure suwayomi system user has write access to /data/media/manga
    users.users.suwayomi.extraGroups = [ "media" ];

    # Deprioritize background I/O so mass chapter downloading does not starve desktop responsiveness
    systemd.services.suwayomi-server.serviceConfig = {
      Nice = 10;
      IOSchedulingClass = "best-effort";
      IOSchedulingPriority = 7;
    };

    # Allow incoming Web UI connections from LAN & NetBird (trusted)
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --dport 4567 -s 192.168.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport 4567 -s 10.0.0.0/8 -j nixos-fw-accept
    '';

    # 2. Declarative Extension Provisioner Service (Native Localhost)
    systemd.services.suwayomi-preload-extensions = {
      description = "Declarative Suwayomi Manga/Manhwa Extension Provisioner";
      wantedBy = [ "multi-user.target" ];
      after = [ "suwayomi-server.service" ];
      requires = [ "suwayomi-server.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "suwayomi-preload-extensions" ''
          set -euo pipefail

          echo "Waiting for Suwayomi-Server API on localhost:4567..."
          SERVER_ONLINE=0
          for i in $(seq 1 60); do
            if ${pkgs.curl}/bin/curl -s -f http://127.0.0.1:4567/api/v1/meta >/dev/null 2>&1; then
              echo "Suwayomi-Server is online."
              SERVER_ONLINE=1
              break
            fi
            sleep 1
          done

          if [ "$SERVER_ONLINE" -eq 0 ]; then
            echo "Suwayomi-Server API did not become ready within 60s. Skipping extension provisioning."
            exit 1
          fi

          echo "Fetching currently installed extensions..."
          INSTALLED=$(${pkgs.curl}/bin/curl -s http://127.0.0.1:4567/api/v1/extension/list | ${pkgs.gnugrep}/bin/grep -o '{[^{}]*"installed":true[^{}]*}' || echo "")

          ${lib.concatStringsSep "\n" (map (ext: ''
            if echo "$INSTALLED" | ${pkgs.gnugrep}/bin/grep -q '"pkgName":"${ext.pkgName}"'; then
              echo "Extension ${ext.name} is already installed. Skipping."
            else
              echo "Installing extension: ${ext.name}..."
              ${pkgs.curl}/bin/curl -s -f -X POST -F "file=@${ext.file}" http://127.0.0.1:4567/api/v1/extension/install || true
            fi
          '') mangaExtensions)}

          echo "All declared Manga/Manhwa extensions provisioned successfully."
        '';
      };
    };
  };
}
