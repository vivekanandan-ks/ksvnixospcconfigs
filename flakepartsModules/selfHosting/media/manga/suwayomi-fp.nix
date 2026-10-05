{ inputs, lib, ... }: {
  flake.nixosModules.selfHosting = lib.mkIf (inputs ? nixflix) {
    # 1. Automated Manga & Manhwa Scraper / Downloader
    services.suwayomi-server = {
      enable = true;
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
          # Preload official Keiyoushi community extension index for one-click source installation
          extensionRepos = [
            "https://raw.githubusercontent.com/keiyoushi/extensions/repo/index.min.json"
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
  };
}
