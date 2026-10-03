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
    ...
  }: {
    imports = lib.optionals (inputs ? nixflix) [
      inputs.nixflix.nixosModules.default
    ];

    config = lib.mkIf (inputs ? nixflix) {
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
    };
  };
}
