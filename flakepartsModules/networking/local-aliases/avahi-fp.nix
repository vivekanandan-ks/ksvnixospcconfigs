{ lib, ... }: {
  flake.nixosModules.localAliases = { config, lib, pkgs, ... }:
  let
    cfg = config.localAliases;
    hasAliases = cfg != { };
  in
  {
    # Base Avahi daemon & Wi-Fi mDNS firewall (always active on host)
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
      openFirewall = false; # Scoped strictly to Wi-Fi below
      denyInterfaces = [ "wt0" "wg-br" "tun0" "tailscale0" "docker0" "podman0" ];
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
    };

    # Prevent systemd-resolved from competing for UDP port 5353
    services.resolved.settings.Resolve.MulticastDNS = "no";

    # Always allow mDNS (UDP 5353) on Wi-Fi so host.local is discoverable
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -i wl+ -p udp --dport 5353 -s 192.168.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -i wl+ -p udp --dport 5353 -s 10.0.0.0/8 -j nixos-fw-accept
    '';

    # Dynamic mDNS alias broadcaster (active only when aliases exist)
    systemd.services.avahi-publish-aliases = lib.mkIf hasAliases {
      description = "Publish dynamic .local mDNS aliases";
      after = [ "network.target" "avahi-daemon.service" ];
      requires = [ "avahi-daemon.service" ];
      wantedBy = [ "multi-user.target" ];

      path = with pkgs; [ avahi iproute2 gawk gnugrep coreutils ];

      serviceConfig = {
        Restart = "always";
        RestartSec = "2s";
        KillMode = "mixed";
      };

      script = ''
        trap 'kill $(jobs -p) 2>/dev/null || true' EXIT SIGTERM SIGINT

        read -r IFACE IP4 < <(ip -4 -br addr show | awk '$1 ~ /^(wl|en|eth)/ && $2 == "UP" {split($3, a, "/"); print $1, a[1]; exit}')
        if [ -z "$IP4" ]; then
          echo "Waiting for active physical LAN interface..." >&2
          exit 1
        fi

        echo "Broadcasting aliases on $IFACE (IPv4: $IP4)"
        for alias in ${lib.escapeShellArgs (lib.attrNames cfg)}; do
          avahi-publish -a -R -f "$alias" "$IP4" &
        done

        IP6=$(ip -6 -br addr show dev "$IFACE" scope global 2>/dev/null | awk '{split($3, a, "/"); print a[1]; exit}')
        if [ -n "$IP6" ]; then
          echo "Broadcasting aliases on $IFACE (IPv6: $IP6)"
          for alias in ${lib.escapeShellArgs (lib.attrNames cfg)}; do
            avahi-publish -a -R -f "$alias" "$IP6" &
          done
        fi

        ( ip monitor address dev "$IFACE" | head -n 1 ) &

        wait -n
        echo "Network change or daemon restart detected. Refreshing aliases..."
        exit 0
      '';
    };
  };
}
