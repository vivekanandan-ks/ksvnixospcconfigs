{ inputs, lib, ... }: {
  flake.nixosModules.selfHosting = lib.mkIf (inputs ? nixflix) {
    nixflix.sonarr = {
      enable = true;
      config = {
        apiKey = "b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6a1";
        hostConfig = {
          username = "admin";
          password = "admin123";
          authenticationRequired = "disabledForLocalAddresses";
        };
      };
    };

    # Allow local home Wi-Fi to reach Sonarr dashboard
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --dport 8989 -s 192.168.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport 8989 -s 10.0.0.0/8 -j nixos-fw-accept
    '';
  };
}
