{ inputs, lib, ... }: {
  flake.nixosModules.selfHosting = lib.mkIf (inputs ? nixflix) (
    let
      port = 8989;
    in
    {
      nixflix.sonarr = {
        enable = true;
        config = {
          apiKey = "b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6a1";
          hostConfig = {
            username = "admin";
            password = "admin123";
            updateMechanism = "external";
          };
        };
      };

      # Expose friendly mDNS domain
      localAliases."sonarr.local" = port;

      # Give Sonarr ample time to initialize SQLite DB without systemd killing it at boot
      systemd.services.sonarr.serviceConfig = {
        TimeoutStartSec = 300;
      };
      systemd.services.sonarr-config.serviceConfig = {
        TimeoutStartSec = 300;
      };

      systemd.services.sonarr-downloadclients = {
        requires = lib.mkForce [ "sonarr.service" "qbittorrent.service" ];
        wants = [ "sonarr-config.service" ];
        serviceConfig = {
          Restart = "on-failure";
          RestartSec = "10s";
        };
      };

      # Allow local home Wi-Fi to reach Sonarr dashboard
      networking.firewall.extraCommands = ''
        iptables -A nixos-fw -p tcp --dport ${toString port} -s 192.168.0.0/16 -j nixos-fw-accept
        iptables -A nixos-fw -p tcp --dport ${toString port} -s 10.0.0.0/8 -j nixos-fw-accept
      '';
    }
  );
}
