{
  inputs,
  lib,
  ...
}: {
  flake.nixosModules.selfHosting = lib.mkIf (inputs ? nixflix) {
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
      "Anime" = {
        collectionType = "tvshows";
        paths = [ "/data/media/anime" ];
        enabled = true;
      };
      "Music" = {
        collectionType = "music";
        paths = [ "/data/media/music" ];
        enabled = true;
      };
      "Home Videos" = {
        collectionType = "homevideos";
        paths = [ "/data/media/videos" ];
        enabled = true;
      };
    };
  };
}
