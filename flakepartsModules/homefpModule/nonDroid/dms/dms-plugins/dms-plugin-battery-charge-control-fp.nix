_: {
  flake.homeModules.nonDroid.dms-plugin-battery-charge-control = _: {
    programs.dank-material-shell.plugins.batteryChargeControl.src = ./dms-battery-charge-control;
  };
}
