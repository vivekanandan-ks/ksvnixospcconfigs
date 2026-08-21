_: {
  flake.homeModules.nonDroid.dms-bottom-bar = {lib, ...}: {
    # Bottom bar commented out
    # programs.dank-material-shell.settings.barConfigs = lib.mkAfter [
    #   {
    #     id = "bottom-plugin-bar";
    #     name = "Bottom Plugin Bar";
    #     enabled = true;
    #     position = 1; # Bottom
    #     autoHide = true;
    #     attachToScreenEdge = false;
    #     clickThrough = false;
    #     noBackground = true;
    #     innerPadding = 2;
    #     widgetPadding = 6;
    #     transparency = 0.5;
    #     widgetTransparency = 0.76;
    #     leftWidgets = [
    #       "mediaControlPlus"
    #       "dankActions"
    #     ];
    #     centerWidgets = [
    #       "hiddenBar"
    #       "systemMonitorPlus"
    #     ];
    #     rightWidgets = [];
    #   }
    # ];
  };
}
