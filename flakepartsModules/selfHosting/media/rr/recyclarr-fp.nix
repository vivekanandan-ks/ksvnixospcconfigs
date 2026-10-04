{ inputs, lib, ... }: {
  flake.nixosModules.selfHosting = lib.mkIf (inputs ? nixflix) {
    nixflix.recyclarr = {
      enable = true;
      radarrQuality = "1080p";
      sonarrQuality = "1080p";

      config = {
        # Movies (Radarr): Ban all Blu-ray / Remux / BR-DISK, prioritize x265 (HD)
        radarr.radarr = {
          quality_profiles = lib.mkForce [
            {
              trash_id = "0896c29d74de619df168d23b98104b22"; # [SQP] SQP-1 (1080p)
              reset_unmatched_scores.enabled = true;
              min_format_score = 180;
              qualities = [
                { name = "BR-DISK"; enabled = false; }
                { name = "Remux-2160p"; enabled = false; }
                { name = "Bluray-2160p"; enabled = false; }
                { name = "Remux-1080p"; enabled = false; }
                { name = "Bluray-1080p"; enabled = false; }
                { name = "Bluray-720p"; enabled = false; }
                { name = "Bluray-576p"; enabled = false; }
                { name = "Bluray-480p"; enabled = false; }
              ];
            }
          ];
          custom_formats = [
            {
              trash_ids = [ "dc980c90d8a571ea86ff546949022646" ]; # x265 (HD)
              assign_scores_to = [
                { trash_id = "0896c29d74de619df168d23b98104b22"; score = 1000; }
              ];
            }
          ];
        };

        # Series (Sonarr): Ban all Blu-ray / Remux, prioritize x265 (HD)
        sonarr.sonarr = {
          quality_profiles = lib.mkForce [
            {
              trash_id = "9d142234e45d6143785ac55f5a9e8dc9"; # WEB-1080p (Alternative)
              reset_unmatched_scores.enabled = true;
              qualities = [
                { name = "Bluray-2160p Remux"; enabled = false; }
                { name = "Bluray-2160p"; enabled = false; }
                { name = "Bluray-1080p Remux"; enabled = false; }
                { name = "Bluray-1080p"; enabled = false; }
                { name = "Bluray-720p"; enabled = false; }
                { name = "Bluray-576p"; enabled = false; }
                { name = "Bluray-480p"; enabled = false; }
              ];
            }
          ];
          custom_formats = [
            {
              trash_ids = [ "47435ece6b99a0b477caf360e79ba0bb" ]; # x265 (HD)
              assign_scores_to = [
                { trash_id = "9d142234e45d6143785ac55f5a9e8dc9"; score = 1000; }
              ];
            }
          ];
        };
      };
    };

    systemd.services.recyclarr = {
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      preStart = lib.mkBefore ''
        # Clear corrupted incomplete clone if FETCH_HEAD is missing
        if [ -d /var/lib/recyclarr/resources/trash-guides/git/official/.git ] && [ ! -f /var/lib/recyclarr/resources/trash-guides/git/official/.git/FETCH_HEAD ]; then
          rm -rf /var/lib/recyclarr/resources/trash-guides/git/official
        fi
      '';
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = "10s";
      };
    };
  };
}
