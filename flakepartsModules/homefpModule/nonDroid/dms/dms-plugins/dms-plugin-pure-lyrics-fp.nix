{inputs, ...}: {
  flake-file.inputs = {
    dms-plugin-pure-lyrics = {
      url = "github:lildengzi/pureLyrics";
      flake = false;
    };
  };

  flake.homeModules.nonDroid.dms-plugin-pure-lyrics = {pkgs, ...}: {
    programs.dank-material-shell.plugins.pureLyrics = {
      enable = true;
      src = pkgs.runCommand "dms-plugin-pure-lyrics-patched" {} ''
            cp -r ${inputs.dms-plugin-pure-lyrics} $out
            chmod -R u+w $out

            substituteInPlace $out/PureLyrics.qml \
              --replace-fail "DesktopPluginComponent {" "DesktopPluginComponent {
        readonly property bool isMusicPlaying: root.lyricPlayer ? (root.lyricPlayer.playbackState === MprisPlaybackState.Playing) : false
        visible: root.isMusicPlaying" \
              --replace-fail "running: root.lyricPlayer && lyricsLines.length > 0" "running: root.isMusicPlaying && lyricsLines.length > 0"
      '';
    };
  };
}
