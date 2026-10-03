{ inputs, lib, ... }: {
  flake.nixosModules.selfHosting = lib.mkIf (inputs ? nixflix) {
    nixflix.prowlarr = {
      enable = true;
      config = {
        apiKey = "c3d4e5f6a7b8c9d0e1f2a3b4c5d6a1b2";
        hostConfig = {
          username = "admin";
          password = "admin123";
          authenticationRequired = "disabledForLocalAddresses";
        };
      };
    };

    # Give Prowlarr ample time to initialize SQLite DB without systemd killing it at boot
    systemd.services.prowlarr.serviceConfig.TimeoutStartSec = 120;
    systemd.services.prowlarr-config.serviceConfig.TimeoutStartSec = 120;

    # Allow local home Wi-Fi to reach Prowlarr dashboard
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --dport 9696 -s 192.168.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport 9696 -s 10.0.0.0/8 -j nixos-fw-accept
    '';
  };
}
