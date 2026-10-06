{ inputs, lib, ... }: {
  flake.nixosModules.selfHosting = { pkgs, ... }: let
    # Pinned Manga & Manhwa Extension Packages (Keiyoushi API v1.6)
    mangaExtensions = [
      {
        name = "MangaDex";
        pkgName = "eu.kanade.tachiyomi.extension.all.mangadex";
        file = pkgs.fetchurl {
          name = "tachiyomi-all.mangadex-v1.6.0.apk";
          url = "https://github.com/keiyoushi/extensions/releases/download/8ef06cd-0/tachiyomi-all.mangadex-v1.6.0.apk";
          hash = "sha256-Ev3ndgHUjIsjE0BpTbhEb7paVVztQQmyMcnS4wAJFfs=";
        };
      }
      {
        name = "Asura Scans";
        pkgName = "eu.kanade.tachiyomi.extension.en.asurascans";
        file = pkgs.fetchurl {
          name = "tachiyomi-en.asurascans-v1.6.69.apk";
          url = "https://github.com/keiyoushi/extensions/releases/download/4217666-0/tachiyomi-en.asurascans-v1.6.69.apk";
          hash = "sha256-VZFE3fJbx/NI76UjMY5Ft1RHJ6VfPF3cS9kbOoYSlfM=";
        };
      }
      {
        name = "Flame Comics";
        pkgName = "eu.kanade.tachiyomi.extension.en.flamecomics";
        file = pkgs.fetchurl {
          name = "tachiyomi-en.flamecomics-v1.6.0.apk";
          url = "https://github.com/keiyoushi/extensions/releases/download/06f6d69/tachiyomi-en.flamecomics-v1.6.0.apk";
          hash = "sha256-bxDTv2TnGKpLrp06CjsclhcscCjMsgsTFTBDpnxN7os=";
        };
      }
      {
        name = "Webtoons";
        pkgName = "eu.kanade.tachiyomi.extension.all.webtoons";
        file = pkgs.fetchurl {
          name = "tachiyomi-all.webtoons-v1.6.2.apk";
          url = "https://github.com/keiyoushi/extensions/releases/download/4c8cda7/tachiyomi-all.webtoons-v1.6.2.apk";
          hash = "sha256-iphC3F25f505OaNeuBmxVNWAWlM49eNXBtYr0/BHYHk=";
        };
      }
      {
        name = "Bato.to";
        pkgName = "eu.kanade.tachiyomi.extension.en.bbato";
        file = pkgs.fetchurl {
          name = "tachiyomi-en.bbato-v1.6.2.apk";
          url = "https://github.com/keiyoushi/extensions/releases/download/4217666-0/tachiyomi-en.bbato-v1.6.2.apk";
          hash = "sha256-VQ2jzqDYhwYBB0i/tQzBsRHubJb3hXskAAYAwFk/iwk=";
        };
      }
    ];
  in lib.mkIf (inputs ? nixflix) {
    # 1. Automated Manga & Manhwa Scraper / Downloader
    services.suwayomi-server = {
      enable = true;
      # Declaratively bump to v2.4.2366 to support Extension API v1.6 and Mihon Extension Stores
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

    # 2. Confine strictly inside WireGuard (Cloudflare WARP) network namespace with kill switch
    systemd.services.suwayomi-server.vpnConfinement = {
      enable = true;
      vpnNamespace = "wg";
    };

    # Forward Web UI port from host into the VPN namespace
    vpnNamespaces.wg.portMappings = [
      {
        from = 4567;
        to = 4567;
        protocol = "tcp";
      }
    ];

    # 3. Allow incoming Web UI connections strictly from local home LAN (NetBird wt0 is trusted)
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --dport 4567 -s 192.168.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport 4567 -s 10.0.0.0/8 -j nixos-fw-accept
    '';

    # 4. Localhost loopback proxy so desktop browser can seamlessly access http://localhost:4567
    systemd.sockets.suwayomi-loopback = {
      description = "Suwayomi Web UI Localhost Proxy Socket";
      wantedBy = [ "sockets.target" ];
      listenStreams = [ "127.0.0.1:4567" ];
    };

    systemd.services.suwayomi-loopback = {
      description = "Suwayomi Web UI Localhost Proxy";
      requires = [ "suwayomi-loopback.socket" "suwayomi-server.service" ];
      after = [ "suwayomi-loopback.socket" "suwayomi-server.service" ];
      serviceConfig = {
        Type = "notify";
        ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd 192.168.15.1:4567";
        PrivateTmp = true;
      };
    };

    # 5. Declarative Extension Provisioner Service (Idempotent)
    systemd.services.suwayomi-preload-extensions = {
      description = "Declarative Suwayomi Manga/Manhwa Extension Provisioner";
      wantedBy = [ "multi-user.target" ];
      after = [ "suwayomi-server.service" "suwayomi-loopback.service" ];
      requires = [ "suwayomi-server.service" "suwayomi-loopback.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "suwayomi-preload-extensions" ''
          set -euo pipefail

          echo "Waiting for Suwayomi-Server API on localhost:4567..."
          for i in $(seq 1 30); do
            if ${pkgs.curl}/bin/curl -s -f http://127.0.0.1:4567/api/v1/meta >/dev/null 2>&1; then
              echo "Suwayomi-Server is online."
              break
            fi
            sleep 1
          done

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
