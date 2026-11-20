_: {
  flake.homeModules.nonDroid.dms-plugin-battery-charge-control = _: {
    programs.dank-material-shell.plugins.batteryChargeControl.src = ./dms-battery-charge-control;

    dms.extraRightWidgets = [
      "batteryPlus"
    ];

    dms.extraControlCenterWidgets = [
      {
        col = 2;
        enabled = true;
        h = 1;
        id = "plugin_batteryChargeControl";
        row = 5;
        w = 2;
      }
    ];
  };
}
