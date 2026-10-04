{ inputs, lib, ... }: {
  flake.nixosModules.selfHosting = { pkgs, ... }: lib.mkIf (inputs ? nixflix) {
    nixflix.radarr = {
      enable = true;
      config = {
        apiKey = "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6";
        hostConfig = {
          username = "admin";
          password = "admin123";
          updateMechanism = "external";
        };
      };
    };

    # Give Radarr ample time to initialize SQLite DB and ensure AllowedHosts is empty so 0.0.0.0 is accepted
    systemd.services.radarr = {
      preStart = ''
        if [ -f /var/lib/radarr/config.xml ]; then
          ${pkgs.gnused}/bin/sed -i 's|<AllowedHosts>.*</AllowedHosts>|<AllowedHosts></AllowedHosts>|g' /var/lib/radarr/config.xml
        fi
      '';
      serviceConfig = {
        TimeoutStartSec = 120;
        Nice = 10;
        IOSchedulingClass = "best-effort";
        IOSchedulingPriority = 7;
      };
    };

    systemd.services.radarr-config.serviceConfig = {
      TimeoutStartSec = 120;
      Nice = 10;
      IOSchedulingClass = "best-effort";
      IOSchedulingPriority = 7;
    };

    systemd.services.radarr-notifications.serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5s";
    };

    # Allow local home Wi-Fi to reach Radarr dashboard
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --dport 7878 -s 192.168.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport 7878 -s 10.0.0.0/8 -j nixos-fw-accept
    '';

    # Bypass Indian ISP dead-routing / 100% packet loss on Cloudflare IP 172.67.180.78
    networking.hosts = {
      "104.21.43.147" = [
        "api.radarr.video"
        "radarr.servarr.com"
      ];
    };
  };
}
