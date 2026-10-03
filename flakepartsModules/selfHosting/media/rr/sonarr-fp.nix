{ inputs, lib, ... }: {
  flake.nixosModules.selfHosting = lib.mkIf (inputs ? nixflix) {
    nixflix.sonarr = {
      enable = true;
      config = {
        apiKey = "b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6a1";
        hostConfig = {
          username = "admin";
          password = "admin123";
        };
      };
    };

    # Give Sonarr ample time to initialize SQLite DB without systemd killing it at boot
    systemd.services.sonarr.serviceConfig = {
      TimeoutStartSec = 120;
      Nice = 10;
      IOSchedulingClass = "best-effort";
      IOSchedulingPriority = 7;
    };
    systemd.services.sonarr-config.serviceConfig = {
      TimeoutStartSec = 120;
      Nice = 10;
      IOSchedulingClass = "best-effort";
      IOSchedulingPriority = 7;
    };

    # Allow local home Wi-Fi to reach Sonarr dashboard
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --dport 8989 -s 192.168.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport 8989 -s 10.0.0.0/8 -j nixos-fw-accept
    '';
  };
}
