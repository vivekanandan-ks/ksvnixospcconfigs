{ ... }: {
  flake.nixosModules.selfHosting = { pkgs, ... }: {
    systemd.services.wgcf-bootstrap = {
      description = "Automated Declarative Cloudflare WARP WireGuard Generator";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      before = [ "wg.service" "vpn-confinement.service" ];
      path = [ pkgs.wgcf pkgs.coreutils pkgs.dnsutils ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        TimeoutStartSec = "120s";
      };

      script = ''
        mkdir -p /var/lib/wireguard
        cd /var/lib/wireguard
        if [ ! -f /var/lib/wireguard/wgcf-profile.conf ]; then
          echo "Waiting for internet/DNS to reach Cloudflare API..."
          for i in $(seq 1 30); do
            if ${pkgs.dnsutils}/bin/nslookup api.cloudflareclient.com >/dev/null 2>&1; then
              echo "Network is online and DNS resolved."
              break
            fi
            echo "Waiting for network connectivity... ($i/30)"
            sleep 2
          done

          wgcf register --accept-tos
          wgcf generate
          chmod 600 wgcf-profile.conf
        fi
      '';
    };

    # Guarantee WireGuard namespace starts ONLY after the profile is generated
    systemd.services.wg = {
      after = [ "wgcf-bootstrap.service" ];
      requires = [ "wgcf-bootstrap.service" ];
    };
  };
}
