{ inputs, lib, ... }: {
  flake.nixosModules.selfHosting = lib.mkIf (inputs ? nixflix) {
    nixflix.recyclarr = {
      enable = true;
      radarrQuality = "1080p";
      sonarrQuality = "1080p";
    };
  };
}
