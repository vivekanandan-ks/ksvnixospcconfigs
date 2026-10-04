{ inputs, lib, ... }: {
  flake.nixosModules.selfHosting = lib.mkIf (inputs ? nixflix) {
    nixflix.recyclarr = {
      enable = true;
      radarrQuality = "1080p";
      sonarrQuality = "1080p";
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
