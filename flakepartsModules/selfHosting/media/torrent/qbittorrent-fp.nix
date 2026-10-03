{ inputs, lib, ... }: {
  flake.nixosModules.selfHosting = lib.mkIf (inputs ? nixflix) {
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
      webuiPort = 8282;
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
        };
      };
    };

    # Allow local home Wi-Fi to reach qBittorrent Web UI
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --dport 8282 -s 192.168.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport 8282 -s 10.0.0.0/8 -j nixos-fw-accept
    '';
  };
}
