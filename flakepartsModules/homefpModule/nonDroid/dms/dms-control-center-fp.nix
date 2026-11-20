_: {
  flake.homeModules.nonDroid.dms-control-center = {config, ...}: let
    baseControlCenterWidgets = [
      # Row 0: User & System Buttons
      {
        col = 0;
        enabled = true;
        h = 1;
        id = "user";
        row = 0;
        w = 5;
      }
      {
        col = 5;
        enabled = true;
        h = 1;
        id = "settings";
        row = 0;
        small = true;
        w = 1;
      }
      {
        col = 6;
        enabled = true;
        h = 1;
        id = "lock";
        row = 0;
        small = true;
        w = 1;
      }
      {
        col = 7;
        enabled = true;
        h = 1;
        id = "power";
        row = 0;
        small = true;
        w = 1;
      }

      # Row 1: Network & Bluetooth
      {
        col = 0;
        enabled = true;
        h = 1;
        id = "wifi";
        row = 1;
        w = 4;
      }
      {
        col = 4;
        enabled = true;
        h = 1;
        id = "bluetooth";
        row = 1;
        w = 4;
      }

      # Row 2: Display & Themes
      {
        col = 0;
        enabled = true;
        h = 1;
        id = "brightnessSlider";
        row = 2;
        w = 4;
      }
      {
        col = 4;
        enabled = true;
        h = 1;
        id = "darkMode";
        row = 2;
        w = 2;
      }
      {
        col = 6;
        enabled = true;
        h = 1;
        id = "nightMode";
        row = 2;
        w = 2;
      }

      # Row 3: Audio Streams
      {
        col = 0;
        enabled = true;
        h = 1;
        id = "audioOutput";
        row = 3;
        w = 4;
      }
      {
        col = 4;
        enabled = true;
        h = 1;
        id = "audioInput";
        row = 3;
        w = 4;
      }

      # Row 4: Quick Toggles
      {
        col = 0;
        enabled = true;
        h = 1;
        id = "idleInhibitor";
        row = 4;
        w = 2;
      }
      {
        col = 2;
        enabled = true;
        h = 1;
        id = "doNotDisturb";
        row = 4;
        w = 2;
      }
      {
        col = 4;
        enabled = true;
        h = 1;
        id = "battery";
        row = 4;
        w = 2;
      }

      # Row 5: Storage & Base Utilities
      {
        col = 0;
        enabled = true;
        h = 1;
        id = "diskUsage";
        instanceId = "default";
        mountPath = "/";
        row = 5;
        w = 2;
      }
      {
        col = 4;
        enabled = true;
        h = 1;
        id = "plugin_dankKDEConnect";
        row = 5;
        w = 2;
      }
      {
        col = 6;
        enabled = true;
        h = 1;
        id = "plugin_takeABreak";
        row = 5;
        w = 2;
      }

      # Row 7 & 8: Edit & Running Apps
      {
        col = 0;
        enabled = true;
        h = 1;
        id = "edit";
        row = 7;
        small = true;
        w = 1;
      }
      {
        col = 0;
        enabled = true;
        h = 1;
        id = "runningApps";
        row = 8;
        small = true;
        w = 4;
      }
    ];
  in {
    programs.dank-material-shell.settings.controlCenterWidgets =
      baseControlCenterWidgets ++ config.dms.extraControlCenterWidgets;
  };
}
