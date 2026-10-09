{ inputs, lib, ... }: {
  flake.nixosModules.selfHosting = { pkgs, ... }: lib.mkIf (inputs ? nixflix) (
    let
      port = 8282;
    in
    {
      # 1. WireGuard Kernel Namespace (Kill Switch)
      nixflix.vpn = {
        enable = true;
        wgConfFile = "/var/lib/wireguard/wgcf-profile.conf";
        # Route local home Wi-Fi and NetBird across the namespace boundary to port 8282
        accessibleFrom = [ "10.0.0.0/8" "192.168.0.0/16" "100.64.0.0/10" ];
      };

      # 2. Confine qBittorrent strictly inside the VPN namespace
      nixflix.torrentClients.qbittorrent = {
        enable = true;
        webuiPort = port;
        password = "adminadmin"; # Used by Radarr/Sonarr to send download tasks
        serverConfig = {
          Preferences = {
            WebUI = {
              Username = "admin";
              Password_PBKDF2 = "@ByteArray(b/j1jih+544rIfvujivl1Q==:ZSYBQtmRBKx3PDcFWMd3yoN3u2mZYYLnCWb7x0A0SWPQjQoiHj64aKLFzEf3R4hWM94qgnQmKYnkIhNrdN0Puw==)";
              AuthSubnetWhitelist = "192.168.15.0/24, 127.0.0.1/32";
              AuthSubnetWhitelistEnabled = true;
              LocalHostAuth = false;
            };
            Bittorrent = {
              MaxRatio = 0;
              MaxRatioAction = 0;
            };
            Connection = {
              GlobalUPLimit = 10;
            };
          };
        };
      };

      # Expose friendly mDNS domain
      localAliases."torrent.local" = port;

      # Allow local home Wi-Fi to reach qBittorrent Web UI
      networking.firewall.extraCommands = ''
        iptables -A nixos-fw -p tcp --dport ${toString port} -s 192.168.0.0/16 -j nixos-fw-accept
        iptables -A nixos-fw -p tcp --dport ${toString port} -s 10.0.0.0/8 -j nixos-fw-accept
      '';

      # 3. Localhost loopback proxy so desktop browser can seamlessly access http://localhost:8282
      systemd.sockets.qbittorrent-loopback = {
        description = "qBittorrent Web UI Localhost Proxy Socket";
        wantedBy = [ "sockets.target" ];
        listenStreams = [ "127.0.0.1:${toString port}" ];
      };

      systemd.services.qbittorrent-loopback = {
        description = "qBittorrent Web UI Localhost Proxy";
        requires = [ "qbittorrent-loopback.socket" ];
        after = [ "qbittorrent-loopback.socket" ];
        serviceConfig = {
          Type = "notify";
          ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd 192.168.15.1:${toString port}";
          PrivateTmp = true;
        };
      };
    }
  );
}
