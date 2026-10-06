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
      TimeoutStartSec = 120;
      Nice = 10;
      IOSchedulingClass = "best-effort";
      IOSchedulingPriority = 7;
    };
    systemd.services.sonarr-anime-config.serviceConfig = {
      TimeoutStartSec = 120;
      Nice = 10;
      IOSchedulingClass = "best-effort";
      IOSchedulingPriority = 7;
    };

    # 2. Co-located Recyclarr Anime Rules
    nixflix.recyclarr.config.sonarr.sonarr_anime = {
      quality_profiles = [
        {
          name = "HD-1080p";
          upgrade.until_quality = "WEBDL-1080p";
          reset_unmatched_scores.enabled = true;
          qualities = [
            { name = "WEBDL-1080p"; enabled = true; }
            { name = "WEBRip-1080p"; enabled = true; }
            # Disallow all Blu-ray and Remux formats
            { name = "Bluray-2160p Remux"; enabled = false; }
            { name = "Bluray-2160p"; enabled = false; }
            { name = "Bluray-1080p Remux"; enabled = false; }
            { name = "Bluray-1080p"; enabled = false; }
            { name = "Bluray-720p"; enabled = false; }
            { name = "Bluray-576p"; enabled = false; }
            { name = "Bluray-480p"; enabled = false; }
            { name = "DVD"; enabled = false; }
            { name = "SDTV"; enabled = false; }
          ];
        }
      ];

      custom_formats = [
        # Prioritize x265 / HEVC Mini-encodes for lowest file size (+1000 pts)
        {
          trash_ids = [ "47435ece6b99a0b477caf360e79ba0bb" ]; # x265 (HD)
          assign_scores_to = [
            { name = "HD-1080p"; score = 1000; }
          ];
        }

        # 1st Choice (+500 pts): Premier Subbed Groups (SubsPlease, Erai-raws)
        {
          trash_ids = [ "e0014372773c8f0e1bef8824f00c7dc4" ]; # Anime Web Tier 01
          assign_scores_to = [
            { name = "HD-1080p"; score = 500; }
          ];
        }

        # 2nd Choice (+100 pts): Dual Audio (Japanese + English)
        {
          trash_ids = [ "418f50b10f1907201b6cfdf881f467b7" ]; # Anime Dual Audio
          assign_scores_to = [
            { name = "HD-1080p"; score = 100; }
          ];
        }

        # Banned (-10,000 pts): Dubs Only (No Japanese audio)
        {
          trash_ids = [ "9c14d194486c4014d422adc64092d794" ]; # Dubs Only
          assign_scores_to = [
            { name = "HD-1080p"; score = -10000; }
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
