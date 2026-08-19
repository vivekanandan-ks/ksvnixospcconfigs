{inputs, ...}: {
  flake-file.inputs = {
    dms-shell = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.homeModules.nonDroid.dms = {config, ...}: {
    imports = [
      inputs.dms-shell.homeModules.default
    ];

    programs.dank-material-shell = {
      enable = true;
      systemd = {
        enable = true;
        target =
          if (config.wayland.windowManager.mango.enable or false)
          then "mango-session.target"
          else "hyprland-session.target";
      };

      enableSystemMonitoring = true;
      enableDynamicTheming = false; # Stylix handles system and app theming
      enableVPN = true;
      enableCalendarEvents = true;

      settings = {
        cornerRadius = 12;
        barElevationEnabled = true;
        m3ElevationIntensity = 8;
        runDmsMatugenTemplates = false;
        showDock = false;

        # Live status icons on the control center bar button
        controlCenterShowNetworkIcon = true;
        controlCenterShowBluetoothIcon = true;
        controlCenterShowAudioIcon = true;
        controlCenterShowAudioPercent = true;
        controlCenterShowVpnIcon = true;

        # Scroll to adjust master volume
        audioScrollMode = "volume";
        audioWheelScrollAmount = 5;
        audioDeviceScrollVolumeEnabled = true;

        barConfigs = [
          {
            id = "default";
            name = "Main Bar";
            enabled = true;
            position = 1; # Bottom bar
            attachToScreenEdge = false;
            bottomGap = 4;
            spacing = 4;
            innerPadding = 4;
            widgetPadding = 8;
            transparency = 0.0;
            widgetTransparency = 0.8;
            squareCorners = false;
            noBackground = true;
            scrollEnabled = true;

            # Left Widgets (Music placed last on left side)
            leftWidgets = [
              "launcherButton"
              "focusedWindow"
              "workspaceSwitcher"
              "music"
            ];

            # Center Widgets
            centerWidgets = [
              "capsLockIndicator"
            ];

            # Right Widgets (Network speed, CPU, RAM, Battery, Tray, Notifs, Clipboard, Clock, Status Icons)
            rightWidgets = [
              "network_speed_monitor"
              "cpuUsage"
              "memUsage"
              "battery"
              "systemTray"
              "notificationButton"
              "clipboard"
              "clock"
              "controlCenterButton"
            ];
          }
        ];
      };
    };
  };
}
