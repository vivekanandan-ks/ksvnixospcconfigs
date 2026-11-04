{inputs, ...}: {
  flake-file.inputs = {
    dms-plugin-screencast-picker = {
      url = "github:psyreactor/dms-screencastPicker";
      flake = false;
    };
  };

  flake.nixosModules.dms-plugin-screencast-picker = _: {
    xdg.portal.wlr.settings.screencast.chooser_cmd = "${inputs.dms-plugin-screencast-picker}/bin/screencast-picker";
  };

  flake.homeModules.nonDroid.dms-plugin-screencast-picker = {pkgs, ...}: {
    programs.dank-material-shell.plugins.screencastPicker = {
      src = inputs.dms-plugin-screencast-picker;
      enable = true;
    };

    dmsExtraPackages = [
      pkgs.grim
    ];
  };
}
