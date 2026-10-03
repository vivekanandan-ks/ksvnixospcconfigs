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
    };

    # Allow local home Wi-Fi to reach qBittorrent Web UI
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --dport 8282 -s 192.168.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport 8282 -s 10.0.0.0/8 -j nixos-fw-accept
    '';
  };
}
