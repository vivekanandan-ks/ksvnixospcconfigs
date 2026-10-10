{ lib, ... }: {
  flake.nixosModules.selfHosting = { pkgs, config, ... }: lib.mkIf (config.nixflix.vpn.enable or false) {
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
        StateDirectory = "wireguard";
        WorkingDirectory = "/var/lib/wireguard";
      };

      script = ''
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

    # Guarantee WireGuard namespace starts ONLY after the profile is generated and endpoint is reachable
    systemd.services.wg = {
      after = [ "wgcf-bootstrap.service" "network-online.target" ];
      wants = [ "network-online.target" "qbittorrent.service" ];
      requires = [ "wgcf-bootstrap.service" ];
      preStart = "${pkgs.iputils}/bin/ping -c 1 -w 120 engage.cloudflareclient.com >/dev/null 2>&1 || true";
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = "5s";
        TimeoutStartSec = "150s";
      };
    };
  };
}
