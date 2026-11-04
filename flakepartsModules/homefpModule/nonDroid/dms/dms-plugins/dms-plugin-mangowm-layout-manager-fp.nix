{inputs, ...}: {
  flake-file.inputs = {
    dms-plugin-mangowm-layout-manager = {
      url = "github:omarluq/DMSMangoWCLayoutManager";
      flake = false;
    };
  };

  flake.homeModules.nonDroid.dms-plugin-mangowm-layout-manager = _: {
    programs.dank-material-shell.plugins.mangoWmLayoutManager = {
      src = inputs.dms-plugin-mangowm-layout-manager;
      enable = true;
    };
  };
}
