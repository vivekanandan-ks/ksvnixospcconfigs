{
  inputs,
  lib,
  ...
}: {
  # 1. Register nixflix flake input for flake-file
  flake-file.inputs = {
    nixflix.url = "github:kiriwalawren/nixflix";
  };

  # 2. Shared selfHosting module
  flake.nixosModules.selfHosting = {
    username,
    pkgs,
    config,
    ...
  }: {
    imports = lib.optionals (inputs ? nixflix) [
      inputs.nixflix.nixosModules.default
    ];

    config = lib.mkIf (inputs ? nixflix) {
      localAliases."jellyfin.local" = config.nixflix.jellyfin.network.internalHttpPort;

      nixflix = {
        enable = true;
        mediaDir = "/data/media";
        stateDir = "/var/lib";
        mediaUsers = [ username ];

        jellyfin = {
          enable = true;

          # Internal API key used by nixflix systemd setup services
          apiKey = "a3b9c8d7e6f5a4b3c2d1e0f9a8b7c6d5";
        };
      };

      # Deprioritize Jellyfin I/O during boot so desktop shell starts immediately
      systemd.services.jellyfin.serviceConfig = {
        Nice = 10;
        IOSchedulingClass = "best-effort";
        IOSchedulingPriority = 7;
      };

      # Automatically trigger a Jellyfin scan whenever new files finish downloading
      systemd.paths.jellyfin-auto-scan = {
        wantedBy = [ "multi-user.target" ];
        pathConfig = {
          PathChanged = [
            "/data/media/movies"
            "/data/media/tv"
            "/data/media/anime"
            "/data/media/music"
          ];
        };
      };

      systemd.services.jellyfin-auto-scan = {
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "-${pkgs.curl}/bin/curl -s -X POST -H 'X-MediaBrowser-Token: a3b9c8d7e6f5a4b3c2d1e0f9a8b7c6d5' http://127.0.0.1:${toString config.nixflix.jellyfin.network.internalHttpPort}/Library/Refresh";
        };
      };
    };
  };
}
