{ inputs, lib, ... }: {
  flake.nixosModules.selfHosting = lib.mkIf (inputs ? nixflix) {
    # 1. Dedicated Sonarr instance for Anime (Port 8990)
    nixflix.sonarr-anime = {
      enable = true;
      config = {
        apiKey = "e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9";
        hostConfig = {
          username = "admin";
          password = "admin123";
          authenticationRequired = "disabledForLocalAddresses";
          updateMechanism = "external";
        };
      };
    };

    # Give Sonarr Anime ample time to initialize SQLite DB without systemd killing it at boot
    systemd.services.sonarr-anime.serviceConfig = {
      TimeoutStartSec = 300;
    };
    systemd.services.sonarr-anime-config.serviceConfig = {
      TimeoutStartSec = 300;
    };

    systemd.services.sonarr-anime-downloadclients = {
      requires = lib.mkForce [ "sonarr-anime.service" "qbittorrent.service" ];
      wants = [ "sonarr-anime-config.service" ];
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = "10s";
      };
    };

    # 2. Allow local home Wi-Fi & NetBird to access Sonarr Anime dashboard
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --dport 8990 -s 192.168.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport 8990 -s 10.0.0.0/8 -j nixos-fw-accept
    '';
  };
}
