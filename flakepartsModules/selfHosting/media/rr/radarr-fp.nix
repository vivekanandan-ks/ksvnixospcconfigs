{ inputs, lib, ... }: {
  flake.nixosModules.selfHosting = lib.mkIf (inputs ? nixflix) {
    nixflix.radarr = {
      enable = true;
      config = {
        apiKey = "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6";
        hostConfig = {
          username = "admin";
          password = "admin123";
          authenticationRequired = "disabledForLocalAddresses";
        };
      };
    };

    # Give Radarr ample time to initialize SQLite DB without systemd killing it at boot
    systemd.services.radarr.serviceConfig.TimeoutStartSec = 120;
    systemd.services.radarr-config.serviceConfig.TimeoutStartSec = 120;

    # Allow local home Wi-Fi to reach Radarr dashboard
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --dport 7878 -s 192.168.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport 7878 -s 10.0.0.0/8 -j nixos-fw-accept
    '';
  };
}
