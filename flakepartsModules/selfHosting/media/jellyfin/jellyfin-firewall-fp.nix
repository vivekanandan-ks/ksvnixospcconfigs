_: {
  flake.hostModules.ksvnixospc.jellyfin-firewall = _: {
    # Keep allowedTCPPorts empty for 8096 so it's NOT exposed globally to the internet.
    # NetBird (wt0) is already trusted in flakepartsModules/networking/netbird-fp.nix.
    networking.firewall.allowedTCPPorts = [];

    # Restrict Jellyfin strictly to local private home subnets (RFC 1918)
    networking.firewall.extraCommands = ''
      # Allow Jellyfin Web / HTTP streaming only from local subnets
      iptables -A nixos-fw -p tcp --dport 8096 -s 192.168.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport 8096 -s 10.0.0.0/8 -j nixos-fw-accept

      # Allow local discovery (Kodi / DLNA) only from local subnets
      iptables -A nixos-fw -p udp --dport 1900 -s 192.168.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -p udp --dport 7359 -s 192.168.0.0/16 -j nixos-fw-accept
    '';
  };
}
