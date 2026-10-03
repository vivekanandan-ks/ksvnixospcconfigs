{ inputs, lib, ... }: {
  flake.nixosModules.selfHosting = lib.mkIf (inputs ? nixflix) {
    nixflix.seerr = {
      enable = true;
      port = 5055;
      apiKey = "d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8";
    };

    # Allow local home Wi-Fi to reach the Seerr web UI
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --dport 5055 -s 192.168.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport 5055 -s 10.0.0.0/8 -j nixos-fw-accept
    '';
  };
}
