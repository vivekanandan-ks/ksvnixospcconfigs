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
        };
      };
    };

    # Give Sonarr Anime ample time to initialize SQLite DB without systemd killing it at boot
    systemd.services.sonarr-anime.serviceConfig.TimeoutStartSec = 120;
    systemd.services.sonarr-anime-config.serviceConfig.TimeoutStartSec = 120;

    # 2. Co-located Recyclarr Anime Rules
    nixflix.recyclarr.config.sonarr.sonarr_anime = {
      quality_profiles = [
        {
          name = "[Anime] Remux-1080p";
          qualities = [
            { name = "Bluray-480p"; enabled = false; }
            { name = "WEB 480p"; enabled = false; }
            { name = "DVD"; enabled = false; }
            { name = "SDTV"; enabled = false; }
          ];
        }
      ];

      custom_formats = [
        # 1st Choice (+500 pts): Premier Subbed Groups (SubsPlease, Erai-raws)
        {
          trash_ids = [ "e0014372773c8f0e1bef8824f00c7dc4" ]; # Anime Web Tier 01
          assign_scores_to = [
            { name = "[Anime] Remux-1080p"; score = 500; }
          ];
        }

        # 2nd Choice (+100 pts): Dual Audio (Japanese + English)
        {
          trash_ids = [ "418f50b10f1907201b6cfdf881f467b7" ]; # Anime Dual Audio
          assign_scores_to = [
            { name = "[Anime] Remux-1080p"; score = 100; }
          ];
        }

        # Banned (-10,000 pts): Dubs Only (No Japanese audio)
        {
          trash_ids = [ "9c14d194486c4014d422adc64092d794" ]; # Dubs Only
          assign_scores_to = [
            { name = "[Anime] Remux-1080p"; score = -10000; }
          ];
        }
      ];
    };

    # 3. Allow local home Wi-Fi & NetBird to access Sonarr Anime dashboard
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --dport 8990 -s 192.168.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport 8990 -s 10.0.0.0/8 -j nixos-fw-accept
    '';
  };
}
