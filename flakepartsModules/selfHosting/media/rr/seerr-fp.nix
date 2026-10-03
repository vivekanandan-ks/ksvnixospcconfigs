{ inputs, lib, ... }: {
  flake.nixosModules.selfHosting = { pkgs, ... }: lib.mkIf (inputs ? nixflix) {
    nixflix.seerr = {
      enable = true;
      port = 5055;
      apiKey = "d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8";
    };

    # Ensure seerr-setup waits for Seerr API to fully initialize before starting
    systemd.services.seerr-setup = {
      serviceConfig.TimeoutStartSec = 300;
      preStart = ''
        echo "Waiting for Seerr API to become responsive..."
        for i in $(seq 1 150); do
          if ${pkgs.curl}/bin/curl -sf http://127.0.0.1:5055/api/v1/status >/dev/null 2>&1; then
            echo "Seerr API is ready."
            exit 0
          fi
          sleep 2
        done
        echo "Timed out waiting for Seerr API"
        exit 1
      '';
    };

    # Allow local home Wi-Fi to reach the Seerr web UI
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --dport 5055 -s 192.168.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport 5055 -s 10.0.0.0/8 -j nixos-fw-accept
    '';
  };
}
