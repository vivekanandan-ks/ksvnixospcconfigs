{ inputs, lib, ... }: {
  flake.nixosModules.selfHosting = lib.mkIf (inputs ? nixflix) {
    nixflix.prowlarr = {
      enable = true;
      config = {
        apiKey = "c3d4e5f6a7b8c9d0e1f2a3b4c5d6a1b2";
        hostConfig = {
          username = "admin";
          password = "admin123";
        };
        indexers = [
          {
            name = "Nyaa.si";
            enable = true;
            appProfileId = 1;
          }
          {
            name = "Tokyo Toshokan";
            enable = true;
            appProfileId = 1;
          }
          {
            name = "YTS";
            enable = true;
            appProfileId = 1;
          }
        ];
      };
    };

    # Give Prowlarr ample time to initialize SQLite DB without systemd killing it at boot
    systemd.services.prowlarr.serviceConfig = {
      TimeoutStartSec = 120;
      Nice = 10;
      IOSchedulingClass = "best-effort";
      IOSchedulingPriority = 7;
    };
    systemd.services.prowlarr-config.serviceConfig = {
      TimeoutStartSec = 120;
      Nice = 10;
      IOSchedulingClass = "best-effort";
      IOSchedulingPriority = 7;
    };

    # Allow local home Wi-Fi to reach Prowlarr dashboard
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --dport 9696 -s 192.168.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport 9696 -s 10.0.0.0/8 -j nixos-fw-accept
    '';
  };
}
