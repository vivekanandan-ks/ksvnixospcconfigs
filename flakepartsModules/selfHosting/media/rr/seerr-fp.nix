{ inputs, lib, ... }: {
  flake.nixosModules.selfHosting = { pkgs, ... }: lib.mkIf (inputs ? nixflix) {
    nixflix.seerr = {
      enable = true;
      port = 5055;
      apiKey = "d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8";

      # Enforce 1080p default request profiles (no more "Any")
      radarr."Radarr" = {
        apiKey = "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6";
        activeProfileName = "my-1080p";
      };
      sonarr."Sonarr" = {
        apiKey = "b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6a1";
        activeProfileName = "my-1080p";
      };
      sonarr."Sonarr Anime" = {
        apiKey = "e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9";
        port = 8990;
        activeDirectory = "/data/media/anime";
        activeAnimeDirectory = "/data/media/anime";
        animeSeriesType = "anime";
        activeAnimeProfileName = "my-1080p";
        activeProfileName = "my-1080p";
      };
    };

    # Ensure seerr-setup waits for Seerr API to fully initialize before starting
    systemd.services.seerr.serviceConfig = {
      Nice = 10;
      IOSchedulingClass = "best-effort";
      IOSchedulingPriority = 7;
    };

    systemd.services.seerr-setup = {
      serviceConfig = {
        TimeoutStartSec = 600;
        Nice = 10;
        IOSchedulingClass = "best-effort";
        IOSchedulingPriority = 7;
      };
      preStart = ''
        echo "Waiting for Seerr API to become responsive..."
        for i in $(seq 1 300); do
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

    # Bypass Indian ISP DNS poisoning (Jio poisons api.themoviedb.org to 49.44.79.236)
    networking.hosts = {
      "13.224.245.47" = [
        "api.themoviedb.org"
      ];
    };
  };
}
