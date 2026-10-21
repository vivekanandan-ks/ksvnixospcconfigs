_: {
  flake.homeModules.nonDroid.dms-plugin-desktop-lyrics = _: {
    programs.dank-material-shell.plugins.desktopLyrics = {
      src = ./dms-desktop-lyrics;
      enable = true;
    };
  };
}
