_: {
  flake.homeModules.nonDroid.dms-bars = {config, ...}: let
    baseLeftWidgets = [
      {
        enabled = true;
        id = "runningApps";
        runningAppsCompactMode = true;
        runningAppsCurrentWorkspace = true;
      }
      {
        enabled = true;
        groupActiveWorkspaceApps = true;
        id = "workspaceSwitcher";
        showOccupiedWorkspacesOnly = true;
        showWorkspaceApps = true;
        showWorkspaceIndex = true;
        showWorkspaceName = true;
        workspaceActiveAppHighlightEnabled = true;
        workspaceFollowFocus = true;
      }
      {
        enabled = true;
        id = "music";
        mediaShowLyrics = false;
        mediaSize = 1;
      }
    ];

    baseCenterWidgets = [];

    baseRightWidgets = [
      "capsLockIndicator"
      {
        enabled = true;
        id = "cpuUsage";
        minimumWidth = false;
      }
      {
        enabled = true;
        id = "memUsage";
        minimumWidth = false;
        showInGb = false;
        showSwap = true;
      }
      "simpleAudioControl"
      {
        enabled = true;
        id = "systemTray";
        trayAutoOverflow = false;
        trayMaxVisibleItems = 1;
        trayPopupSingleLine = true;
        trayUseInlineExpansion = false;
      }
      "notificationButton"
      {
        clockClickAction = "dash";
        clockCompactMode = true;
        enabled = true;
        id = "clock";
      }
      {
        enabled = true;
        id = "controlCenterButton";
        showAudioIcon = false;
        showBatteryIcon = false;
        showBrightnessIcon = false;
        showBrightnessPercent = false;
        showDoNotDisturbIcon = false;
        showIdleInhibitorIcon = true;
        showMicIcon = false;
        showMicPercent = false;
        showPrinterIcon = false;
      }
      {
        enabled = true;
        id = "scratchpadHelper";
        overflowMode = "always";
      }
      {
        enabled = true;
        id = "ambientSound";
        overflowMode = "always";
      }
      {
        enabled = true;
        id = "storageMonitor";
        overflowMode = "always";
      }
      {
        enabled = true;
        id = "dankCleaner";
        overflowMode = "always";
      }
      {
        enabled = true;
        id = "caffeineRedesigned";
        overflowMode = "always";
      }
      {
        enabled = true;
        id = "quickCapture";
        overflowMode = "always";
      }
      {
        enabled = true;
        id = "clipboardPlus";
        overflowMode = "always";
      }
      {
        enabled = true;
        id = "dankKDEConnect";
        overflowMode = "always";
      }
      {
        enabled = true;
        id = "notepadButton";
        overflowMode = "always";
      }
      {
        enabled = true;
        id = "cast";
        overflowMode = "always";
      }
      {
        enabled = true;
        id = "smartTimer";
        overflowMode = "always";
      }
    ];
  in {
    programs.dank-material-shell.settings.barConfigs = [
      {
        attachToScreenEdge = false;
        autoHide = false;
        barInsetPadding = 0;
        batteryColorMode = "theme";
        borderEnabled = false;
        bottomGap = 0;
        clickThrough = false;
        enabled = true;
        followInterfaceStyle = true;
        gothCornersEnabled = false;
        hoverPopouts = false;
        id = "default";
        innerPadding = -4;

        # Directional append rules:
        # Left widgets append on the right
        leftWidgets = baseLeftWidgets ++ config.dms.extraLeftWidgets;
        # Middle widgets append on the right
        centerWidgets = baseCenterWidgets ++ config.dms.extraCenterWidgets;
        # Right widgets append on the left (prepend)
        rightWidgets = config.dms.extraRightWidgets ++ baseRightWidgets;

        maximizeDetection = true;
        maximizeWidgetIcons = false;
        maximizeWidgetText = false;
        name = "Main Bar";
        noBackground = true;
        popupGapsAuto = true;
        popupGapsManual = 4;
        position = 0;
        rightOverflowMode = "auto";
        rightOverflowPosition = 11;
        screenPreferences = [
          "all"
        ];
        scrollEnabled = true;
        shadowIntensity = 0;
        shadowOpacity = 0;
        spacing = 0;
        squareCorners = false;
        transparency = 0.5;
        useOverlayLayer = false;
        widgetFollowInterfaceStyle = false;
        widgetOutlineColor = "primary";
        widgetOutlineEnabled = false;
        widgetOutlineOpacity = 0.5;
        widgetOutlineThickness = 1;
        widgetPadding = 6;
        widgetTransparency = 0.76;
      }
      {
        attachToScreenEdge = false;
        autoHide = false;
        autoHideDelay = 250;
        autoHideStrict = false;
        barLengthPadding = 0;
        borderColor = "surfaceText";
        borderEnabled = false;
        borderOpacity = 1;
        borderThickness = 1;
        bottomGap = 0;
        centerWidgets = [];
        enabled = false;
        followInterfaceStyle = true;
        fontScale = 1;
        gothCornerRadiusOverride = false;
        gothCornerRadiusValue = 12;
        gothCornersEnabled = false;
        hoverPopoutDelay = 150;
        hoverPopouts = false;
        iconScale = 1;
        id = "bar1788526942115";
        innerPadding = -4;
        leftWidgets = [];
        maximizeDetection = true;
        maximizeWidgetIcons = false;
        maximizeWidgetText = false;
        name = "Bar 2";
        noBackground = true;
        openOnOverview = false;
        popupGapsAuto = true;
        popupGapsManual = 4;
        position = 1;
        rightOverflowMode = "auto";
        rightOverflowPosition = 1;
        rightWidgets = [];
        screenPreferences = [
          "all"
        ];
        scrollEnabled = true;
        scrollXBehavior = "focusWindow";
        scrollYBehavior = "workspace";
        shadowColorMode = "default";
        shadowCustomColor = "#000000";
        shadowDirection = "top";
        shadowDirectionMode = "inherit";
        shadowIntensity = 0;
        shadowOpacity = 0;
        showOnLastDisplay = false;
        showOnWindowsOpen = false;
        spacing = 0;
        squareCorners = false;
        transparency = 0.5;
        useOverlayLayer = false;
        visible = true;
        widgetFollowInterfaceStyle = false;
        widgetOutlineColor = "primary";
        widgetOutlineEnabled = false;
        widgetOutlineOpacity = 0.5;
        widgetOutlineThickness = 1;
        widgetPadding = 6;
        widgetTransparency = 0.76;
      }
      {
        dot = false;
        enabled = true;
        hideOnLastDisplay = false;
        hoverPopouts = false;
        id = "island";
        island = true;
        islandDashTabs = true;
        islandFloating = true;
        islandFreeIconMode = "os";
        islandHomeClockDisplay = "date";
        islandHomeCompactTight = true;
        islandMediaAutoSwitch = true;
        islandMediaLyrics = true;
        islandNotificationExpand = false;
        islandNotificationPopups = true;
        islandPlacement = "free";
        islandRouteClipboard = "island";
        islandRouteControlCenter = "island";
        islandRouteDash = "island";
        islandRouteLauncher = "island";
        islandRouteMedia = "island";
        islandRouteNotificationCenter = "island";
        islandRoutePowerMenu = "follow";
        islandRouteWallpaper = "island";
        islandRouteWeather = "island";
        islandSatelliteBackground = false;
        islandSatellitePosition = "edges";
        islandSatellitesEnabled = false;
        islandSpringDamping = 37;
        islandSpringMass = 1;
        islandSpringStiffness = 560;
        islandSystemOsd = false;
        islandUseOverlayLayer = false;
        leftWidgets = [
          {
            enabled = true;
            id = "launcherButton";
          }
          {
            enabled = true;
            id = "workspaceSwitcher";
          }
          {
            enabled = true;
            id = "focusedWindow";
          }
        ];
        name = "Dynamic Island";
        noBackground = false;
        position = 0;
        rightWidgets = [
          {
            enabled = true;
            id = "systemTray";
          }
          {
            enabled = true;
            id = "clipboard";
          }
          {
            enabled = true;
            id = "notificationButton";
          }
          {
            enabled = true;
            id = "battery";
          }
          {
            enabled = true;
            id = "controlCenterButton";
          }
        ];
        screenPreferences = [
          "all"
        ];
        scrollYBehavior = "workspace";
        showOnLastDisplay = true;
        widgetFollowInterfaceStyle = true;
        widgetOutlineEnabled = false;
        widgetOutlineOpacity = 1;
        widgetOutlineThickness = 1;
        widgetStyle = "pills";
        innerPadding = -4;
        widgetPadding = 5;
        islandCompactThickness = 32;
        islandSatelliteGap = 6;
      }
      {
        dot = true;
        enabled = false;
        hideOnLastDisplay = false;
        hoverPopouts = false;
        id = "dot1793803203982";
        island = false;
        islandDashTabs = true;
        islandFloating = true;
        islandFreeIconMode = "os";
        islandHomeClockDisplay = "date";
        islandHomeCompactTight = true;
        islandMediaAutoSwitch = true;
        islandMediaLyrics = true;
        islandNotificationExpand = false;
        islandNotificationPopups = true;
        islandPlacement = "free";
        islandRouteClipboard = "island";
        islandRouteControlCenter = "island";
        islandRouteDash = "island";
        islandRouteLauncher = "island";
        islandRouteMedia = "island";
        islandRouteNotificationCenter = "island";
        islandRoutePowerMenu = "follow";
        islandRouteWallpaper = "island";
        islandRouteWeather = "island";
        islandSatelliteBackground = false;
        islandSatellitePosition = "edges";
        islandSatellitesEnabled = false;
        islandSpringDamping = 37;
        islandSpringMass = 1;
        islandSpringStiffness = 560;
        islandSystemOsd = false;
        islandUseOverlayLayer = false;
        leftWidgets = [
          {
            enabled = true;
            id = "launcherButton";
          }
          {
            enabled = true;
            id = "workspaceSwitcher";
          }
          {
            enabled = true;
            id = "focusedWindow";
          }
        ];
        name = "Dot";
        noBackground = false;
        position = 0;
        rightWidgets = [
          {
            enabled = true;
            id = "systemTray";
          }
          {
            enabled = true;
            id = "clipboard";
          }
          {
            enabled = true;
            id = "notificationButton";
          }
          {
            enabled = true;
            id = "battery";
          }
          {
            enabled = true;
            id = "controlCenterButton";
          }
        ];
        screenPreferences = [
          "all"
        ];
        scrollYBehavior = "workspace";
        showOnLastDisplay = true;
        widgetFollowInterfaceStyle = true;
        widgetOutlineEnabled = false;
        widgetOutlineOpacity = 1;
        widgetOutlineThickness = 1;
        widgetStyle = "pills";
        innerPadding = -4;
        widgetPadding = 5;
        islandCompactThickness = 32;
        islandSatelliteGap = 6;
        visible = true;
        autoHide = false;
        followInterfaceStyle = false;
        transparency = 0.5;
      }
    ];
  };
}
