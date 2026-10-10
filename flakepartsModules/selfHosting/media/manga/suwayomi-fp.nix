{
  inputs,
  lib,
  ...
}: {
  flake.nixosModules.selfHosting = {pkgs, ...}: let
    port = 4567;

    # Declarative extension packages (Pre-compiled desktop JARs bypassing dex2jar)
    mangaExtensions = [
      # 1. MangaDex
      {
        name = "MangaDex";
        pkgName = "eu.kanade.tachiyomi.extension.all.mangadex";
        file = pkgs.fetchurl {
          name = "tachiyomi-all.mangadex-v1.6.0.jar";
          url = "https://github.com/keiyoushi/extensions/releases/download/f303b9c/tachiyomi-all.mangadex-v1.6.0.jar";
          hash = "sha256-J4HYWT1o8uea1U8glJOZxEr7cD1WeSmfhPc1bfaXAI4=";
        };
      }
      # 2. Mangakakalot
      {
        name = "Mangakakalot";
        pkgName = "eu.kanade.tachiyomi.extension.en.mangakakalot";
        file = pkgs.fetchurl {
          name = "tachiyomi-en.mangakakalot-v1.6.24.jar";
          url = "https://github.com/keiyoushi/extensions/releases/download/19c8e5f-0/tachiyomi-en.mangakakalot-v1.6.24.jar";
          hash = "sha256-NBby4L8/ggd0NxJCL3ZzD26R+GbpzomD+E+aFFJu5EM=";
        };
      }
      # 3. Asura Scans
      {
        name = "Asura Scans";
        pkgName = "eu.kanade.tachiyomi.extension.en.asurascans";
        file = pkgs.fetchurl {
          name = "tachiyomi-en.asurascans-v1.6.69.jar";
          url = "https://github.com/keiyoushi/extensions/releases/download/19c8e5f-0/tachiyomi-en.asurascans-v1.6.69.jar";
          hash = "sha256-fqoeB+rnuTSkfWUJLi+xJjIsm4/GuVtdAbQ2yy4/zqA=";
        };
      }
      # 4. Flame Comics (temporarily disabled: upstream flamecomics.xyz domain migrated/redirects to Discord)
      # {
      #   name = "Flame Comics";
      #   pkgName = "eu.kanade.tachiyomi.extension.en.flamecomics";
      #   file = pkgs.fetchurl {
      #     name = "tachiyomi-en.flamecomics-v1.6.0.jar";
      #     url = "https://github.com/keiyoushi/extensions/releases/download/06f6d69/tachiyomi-en.flamecomics-v1.6.0.jar";
      #     hash = "sha256-x+vQ2VFnjNBOZTwUk/bZgPm+OjrnKQru1tGjMJzCwoo=";
      #   };
      # }
      # 5. MangaFire
      {
        name = "MangaFire";
        pkgName = "eu.kanade.tachiyomi.extension.all.mangafire";
        file = pkgs.fetchurl {
          name = "tachiyomi-all.mangafire-v1.6.34.jar";
          url = "https://github.com/keiyoushi/extensions/releases/download/19c8e5f-0/tachiyomi-all.mangafire-v1.6.34.jar";
          hash = "sha256-uMC0JXRE2Lj/Ki41RFZV1zBa57jszmNcqRqhcw9fer4=";
        };
      }
    ];
  in
    lib.mkIf (inputs ? nixflix) {
      # 1. Automated Manga & Manhwa Scraper / Downloader
      services.suwayomi-server = {
        enable = true;
        # Bump to v2.4.2366 to support Extension API v1.6 and Mihon Extension Stores
        package = pkgs.suwayomi-server.overrideAttrs (_old: rec {
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
            autoDownloadNewChapters = true;
            excludeEntryWithUnreadChapters = false;
            systemTrayEnabled = false;
            initialOpenInBrowserEnabled = false;
            extensionStores = [
              "https://raw.githubusercontent.com/keiyoushi/extensions/repo/index.json"
            ];
            # Automated Cloudflare bypass via localhost FlareSolverr
            flareSolverrEnabled = true;
            flareSolverrUrl = "http://127.0.0.1:8191";
            flareSolverrTimeout = 60;
            flareSolverrSessionName = "suwayomi";
            flareSolverrSessionTtl = 5;
            flareSolverrAsResponseFallback = true;
          };
        };
      };

      # Ensure suwayomi system user has write access to /data/media/manga
      users.users.suwayomi.extraGroups = ["media"];

      # HotSpot JVM flag to avoid VerifyError on minified / transpiled bytecode
      systemd.services.suwayomi-server.environment = {
        JAVA_TOOL_OPTIONS = "-Xverify:none";
      };

      # Guard suwayomi startup: strictly wait for /data/media/manga filesystem mount
      systemd.services.suwayomi-server.unitConfig = {
        RequiresMountsFor = ["/data/media/manga"];
      };

      # Deprioritize background I/O so mass chapter downloading does not starve desktop responsiveness
      systemd.services.suwayomi-server.serviceConfig = {
        Nice = 10;
        IOSchedulingClass = "best-effort";
        IOSchedulingPriority = 7;
      };

      # Expose friendly mDNS domain
      localAliases."suwayomi.local" = port;

      # Allow incoming Web UI connections from LAN & NetBird (trusted)
      networking.firewall.extraCommands = ''
        iptables -A nixos-fw -p tcp --dport ${toString port} -s 192.168.0.0/16 -j nixos-fw-accept
        iptables -A nixos-fw -p tcp --dport ${toString port} -s 10.0.0.0/8 -j nixos-fw-accept
      '';

      # 2. Declarative Extension Provisioner & Settings Service (Native Localhost)
      systemd.services.suwayomi-preload-extensions = {
        description = "Declarative Suwayomi Manga/Manhwa Extension Provisioner";
        wantedBy = ["multi-user.target"];
        after = ["suwayomi-server.service"];
        requires = ["suwayomi-server.service"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          TimeoutStartSec = "360s";
          ExecStart = pkgs.writeShellScript "suwayomi-preload-extensions" ''
            set -euo pipefail

            echo "Waiting for Suwayomi-Server API on localhost:${toString port}..."
            SERVER_ONLINE=0
            for i in $(seq 1 300); do
              if ${pkgs.curl}/bin/curl -s -f http://127.0.0.1:${toString port}/api/v1/meta >/dev/null 2>&1; then
                echo "Suwayomi-Server is online."
                SERVER_ONLINE=1
                break
              fi
              sleep 1
            done

            if [ "$SERVER_ONLINE" -eq 0 ]; then
              echo "Suwayomi-Server API did not become ready within 300s. Skipping extension provisioning."
              exit 1
            fi

            # Declaratively enforce Download Ahead (Auto download while reading = OFF / 0)
            ${pkgs.curl}/bin/curl -s -X POST -H "Content-Type: application/json" \
              -d '{"query":"mutation { setGlobalMeta(input: { meta: { key: \"webUI_downloadAheadLimit\", value: \"0\" } }) { clientMutationId } }"}' \
              http://127.0.0.1:4567/api/graphql >/dev/null 2>&1 || true

            STATE_DIR="/var/lib/suwayomi-server"

            ${lib.concatStringsSep "\n" (map (ext: ''
                MARKER="$STATE_DIR/.nix-ext-${ext.pkgName}"
                if [ -f "$MARKER" ] && [ "$(cat "$MARKER" 2>/dev/null)" = "${ext.file}" ]; then
                  echo "Extension ${ext.name} is up-to-date. Skipping."
                else
                  echo "Provisioning extension: ${ext.name} (${ext.pkgName})..."
                  # Uninstall any existing/broken version first
                  ${pkgs.curl}/bin/curl -s "http://127.0.0.1:4567/api/v1/extension/uninstall/${ext.pkgName}" >/dev/null 2>&1 || true
                  if ${pkgs.curl}/bin/curl -s -f -X POST -F "file=@${ext.file}" http://127.0.0.1:4567/api/v1/extension/install >/dev/null 2>&1; then
                    echo "${ext.file}" > "$MARKER"
                    echo "Successfully installed ${ext.name}."
                  else
                    echo "Warning: Failed to install ${ext.name}."
                  fi
                fi
              '')
              mangaExtensions)}

            echo "All declared Manga/Manhwa extensions provisioned successfully."
          '';
        };
      };
    };
}
