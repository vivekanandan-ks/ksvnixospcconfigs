{ ... }: {
  flake.nixosModules.selfHosting = { pkgs, ... }: {
    systemd.services.wgcf-bootstrap = {
      description = "Automated Declarative Cloudflare WARP WireGuard Generator";
      wantedBy = [ "multi-user.target" ];
      before = [ "vpn-confinement.service" ];
      path = [ pkgs.wgcf pkgs.coreutils ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        mkdir -p /var/lib/wireguard
        if [ ! -f /var/lib/wireguard/wgcf-profile.conf ]; then
          cd /var/lib/wireguard
          wgcf register --accept-tos
          wgcf generate
          chmod 600 wgcf-profile.conf
        fi
      '';
    };
  };
}
