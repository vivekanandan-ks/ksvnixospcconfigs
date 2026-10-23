_: {
  flake-file.inputs = {
    dms-plugins-sitolam = {
      url = "github:sitolam/dms-plugins";
      flake = false;
    };
  };

  flake.homeModules.nonDroid.dms-plugin-bardropdown = _: {
    programs.dank-material-shell.plugins.barDropdown.enable = false;
  };
}
