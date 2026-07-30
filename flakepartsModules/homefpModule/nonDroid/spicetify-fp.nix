{inputs, ...}: {
  flake-file.inputs = {
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
  };

  flake = {
    homeModules.nonDroid.spicetify = { pkgs, self, ... }: {
      home.packages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.ksvSpicetify
      ];
    };
  };

  perSystem = {
    pkgs,
    inputs',
    ...
  }: {
    packages.ksvSpicetify = let
      spicePkgs = inputs'.spicetify-nix.legacyPackages;
    in
      inputs.spicetify-nix.lib.mkSpicetify pkgs {
        #theme = spicePkgs.themes.catppuccin; # hazy
        theme = spicePkgs.themes.hazy ;
        #colorScheme = "mocha";

        enabledExtensions = with spicePkgs.extensions; [
          # https://gerg-l.github.io/spicetify-nix/extensions.html
          #hidePodcasts
          adblockify
          shuffle # shuffle+ (special characters are sanitized out of extension names)
          bookmark
          loopyLoop
          popupLyrics

          # Community Extensions
          groupSession
          powerBar
          seekSong
          playlistIcons
          fullAlbumDate
          goToSong
          listPlaylistsWithSong
          playlistIntersection
          skipStats
          #phraseToPlaylist
          # wikify
          songStats
          showQueueDuration
          copyToClipboard
          history
          betterGenres
          #adblock
          volumePercentage
          playingSource
          sectionMarker
          queueTime
          coverAmbience
          sleepTimer
          oldCoverClick
          bestMoment
          sortPlay
          availabilityMap
          extendedCopy
          madeForYouShortcut
          sessionStats
          sidebarCustomizer
        ];

        enabledCustomApps = with spicePkgs.apps; [
          newReleases
          historyInSidebar
        ];
      };
  };
}
