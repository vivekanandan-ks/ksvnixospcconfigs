{
  inputs,
  lib,
  ...
}: {
  flake.hostModules.ksvnixospc.jellyfin-libraries = lib.mkIf (inputs ? nixflix) {
    nixflix.jellyfin.libraries = {
      "Movies" = {
        collectionType = "movies";
        paths = [ "/data/media/movies" ];
        enabled = true;
      };
      "TV Shows" = {
        collectionType = "tvshows";
        paths = [ "/data/media/shows" ];
        enabled = true;
      };
    };
  };
}
