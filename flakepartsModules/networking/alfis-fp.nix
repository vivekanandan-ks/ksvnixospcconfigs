_: {
  flake.nixosModules.alfis = {
    pkgs,
    pkgs-unstable,
    ...
  }: let
    alfisConfig = (pkgs-unstable.formats.toml {}).generate "alfis.toml" {
      # Genesis block hash of the Alfis blockchain (mandatory for consensus)
      origin = "0000001D2A77D63477172678502E51DE7F346061FF7EB188A2445ECA3FC0780E";

      net = {
        peers = [
          "peer-v4.alfis.name:4244"
          "peer-v6.alfis.name:4244"
          "peer-ygg.alfis.name:4244"
        ];
        listen = "[::]:4244";
        public = true;
        yggdrasil_only = false;
      };

      dns = {
        listen = "127.0.0.1:5335";
        threads = 4;
        cache_memory_limit_mb = 100;
        forwarders = ["1.1.1.1:53"];
        bootstraps = ["9.9.9.9:53"];
      };

      mining = {
        threads = 0;
        lower = true;
      };
    };
  in {
    # Desktop GUI app available in app launcher
    environment.systemPackages = [
      pkgs-unstable.alfis
    ];

    # Headless 24/7 background DNS resolver
    systemd.services.alfis = {
      description = "Alfis Decentralized DNS Daemon";
      after = ["network.target" "yggdrasil.service"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        ExecStart = "${pkgs-unstable.alfis}/bin/alfis -n -c ${alfisConfig}";
        StateDirectory = "alfis";
        WorkingDirectory = "/var/lib/alfis";
        Restart = "always";
        RestartSec = "5s";
        CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
      };
    };

    # Split DNS: Route .ygg and .anon to Alfis strictly on the Yggdrasil interface
    # without hijacking global system DNS in resolved.conf
    systemd.services.alfis-dns-route = {
      description = "Split DNS routing for Alfis (.ygg and .anon via Yggdrasil interface)";
      after = ["alfis.service" "yggdrasil.service" "systemd-resolved.service"];
      wants = ["alfis.service" "yggdrasil.service" "systemd-resolved.service"];
      partOf = ["yggdrasil.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "alfis-dns-route" ''
          for i in $(seq 1 30); do
            IFACE=""
            if ${pkgs.iproute2}/bin/ip link show tun0 >/dev/null 2>&1; then
              IFACE="tun0"
            elif ${pkgs.iproute2}/bin/ip link show ygg0 >/dev/null 2>&1; then
              IFACE="ygg0"
            fi
            if [ -n "$IFACE" ]; then
              ${pkgs.systemd}/bin/resolvectl dns "$IFACE" 127.0.0.1:5335
              ${pkgs.systemd}/bin/resolvectl domain "$IFACE" "~ygg" "~anon"
              ${pkgs.systemd}/bin/resolvectl default-route "$IFACE" no
              ${pkgs.systemd}/bin/resolvectl dnsovertls "$IFACE" no
              ${pkgs.systemd}/bin/resolvectl dnssec "$IFACE" no
              exit 0
            fi
            sleep 1
          done
          echo "Warning: Yggdrasil interface (tun0/ygg0) not found within 30 seconds."
          exit 0
        '';
      };
    };
  };
}
