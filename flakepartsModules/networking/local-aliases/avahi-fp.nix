_: {
  flake.nixosModules.localServices = {
    # Base Avahi daemon & Wi-Fi mDNS firewall (always active on host)
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
      openFirewall = false; # Scoped strictly to Wi-Fi below
      settings = {
        server = {
          deny-interfaces = ["wt0" "wg0" "wg-br" "veth-wg-br" "fips0" "tun0" "tailscale0" "docker0" "podman0"];
        };
        publish = {
          disable-publishing = false;
          disable-user-service-publishing = false;
          publish-addresses = true;
          publish-workstation = true; # Naturally exposes <hostname>.local on LAN
        };
      };
    };

    # Silence dbus-broker warning about missing upstream netdev group
    users.groups.netdev = {};

    # Prevent systemd-resolved from competing for UDP port 5353
    services.resolved.settings.Resolve.MulticastDNS = "no";

    # Always allow mDNS (UDP 5353) on Wi-Fi so host.local is discoverable
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -i wl+ -p udp --dport 5353 -s 192.168.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -i wl+ -p udp --dport 5353 -s 10.0.0.0/8 -j nixos-fw-accept
    '';
  };
}
