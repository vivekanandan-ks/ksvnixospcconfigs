_: {
  flake.homeModules.nonDroid.dms-plugin-compact-network = _: {
    programs.dank-material-shell.plugins.compactNetwork = {
      src = ./dms-compact-network;
      enable = true;
    };

    dms.extraRightWidgets = [
      "compactNetwork"
    ];
  };
}
