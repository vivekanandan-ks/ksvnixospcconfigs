{ inputs, lib, ... }: {
  flake.nixosModules.selfHosting = { pkgs, ... }: lib.mkIf (inputs ? nixflix) {
    # 1. Native NixOS Bazarr Subtitle Manager Service
    services.bazarr = {
      enable = true;
      user = "bazarr";
      group = "media";

      settings = {
        # --- General & Sidecar Subtitle Placement ---
        general = {
          port = 6767;
          instance_name = "Homelab Bazarr";

          # Master Integration Toggles (Required by Bazarr to activate workers)
          use_radarr = true;
          use_sonarr = true;
          use_jellyfin = true;

          # Subtitle placement: Save directly in the movie/show folder alongside the video file
          subfolder = "current";

          # File permissions: rw-rw-r-- owned by bazarr:media
          chmod_enabled = true;
          chmod = "0664";

          # Hearing Impaired tag: .eng.sdh.srt
          hi_extension = "sdh";

          # Re-encode downloaded subtitles to universal UTF-8
          utf8_encode = true;

          # --- Accuracy & Quality Rules (TRaSH Guides Standards) ---
          minimum_score_movie = 80;
          minimum_score = 80;
          use_scenename = true;

          # Auto-upgrade to a higher-scoring match if uploaded within 7 days
          upgrade_subs = true;
          days_to_upgrade_subs = 7;

          # Force text .srt download if release only has image-based (PGS/VobSub) subtitles
          use_embedded_subs = true;
          embedded_subs_show_desired = true;
          ignore_pgs_subs = true;
          ignore_vobsub_subs = true;

          # Account-free subtitle providers (matched by hash & release name)
          enabled_providers = [
            "bsplayer"
            "embeddedsubtitles"
          ];

          multithreading = true;
          concurrent_jobs = 4;
        };

        # --- Automatic Audio-Subtitle Synchronization (Subsync) ---
        subsync = {
          use_subsync = true;
          use_subsync_movie_threshold = true;
          subsync_movie_threshold = 80;
          max_offset_seconds = 60;
          no_fix_framerate = true;
        };

        # --- Radarr Integration (Movies) ---
        radarr = {
          ip = "127.0.0.1";
          port = 7878;
          base_url = "/";
          ssl = false;
          apikey = "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6"; # Matches radarr-fp.nix
          only_monitored = true;
          movies_sync_on_live = true;
        };

        # --- Sonarr Integration (Standard TV Only) ---
        sonarr = {
          ip = "127.0.0.1";
          port = 8989; # Strictly Standard Sonarr (Port 8990 Anime is completely ignored)
          base_url = "/";
          ssl = false;
          apikey = "b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6a1"; # Matches sonarr-fp.nix
          only_monitored = true;
          series_sync_on_live = true;

          # Guard: Ignore anime if accidentally present in standard Sonarr
          excluded_series_types = [ "Anime" ];
        };

        # --- Jellyfin Integration (Instant Library Refresh) ---
        jellyfin = {
          url = "http://127.0.0.1:8096";
          apikey = "a3b9c8d7e6f5a4b3c2d1e0f9a8b7c6d5"; # Matches jellyfin-core-fp.nix
          update_movie_library = true;
          update_series_library = true;
          refresh_method = "immediate";
        };

        # --- Authentication / Internal API Key ---
        auth = {
          apikey = "c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8";
        };
      };
    };

    # Ensure bazarr user has secondary access to media group
    users.users.bazarr.extraGroups = [ "media" ];

    # Deprioritize CPU and I/O so subsync voice detection runs purely in the background without affecting desktop or playback
    systemd.services.bazarr.serviceConfig = {
      Nice = 19;
      IOSchedulingClass = "idle";
    };

    # Provide ffmpeg to Bazarr for audio sync (subsync) and embedded subtitle detection
    systemd.services.bazarr.path = [
      pkgs.ffmpeg-headless
    ];

    # Restrict web UI to local home Wi-Fi and NetBird VPN
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --dport 6767 -s 192.168.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport 6767 -s 10.0.0.0/8 -j nixos-fw-accept
    '';
  };
}
