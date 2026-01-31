{
  #inputs,
  #config,
  lib,
  #pkgs,
  pkgs-unstable,
  ...
}: {
  programs.noctalia-shell = {
    #enable = true;

    settings = {
      settingsVersion = 0;

      # --- Top Bar (Matching Plasma Top Panel) ---
      bar = {
        barType = "simple";
        position = "bottom";
        monitors = [ ];
        density = "default";
        showOutline = false;
        showCapsule = true;
        capsuleOpacity = lib.mkForce 1;
        backgroundOpacity = lib.mkForce 0.8; # Translucent as per Plasma config
        useSeparateOpacity = false;
        floating = false; # Plasma top panel was floating but "fit", here standard bar is safer
        marginVertical = 4;
        marginHorizontal = 4;
        frameThickness = 8;
        frameRadius = 12;
        outerCorners = true;
        exclusive = true;
        hideOnOverview = false;

        widgets = {
          left = [
            # Plasma: Window Title, Global Menu
            { id = "Launcher"; icon = "nix-snowflake"; } # Moved here for easy access, or can rely on Dock
            { id = "ActiveWindow"; } # Replaces Window Title
            { id = "Workspace"; }    # Replaces Pager
          ];
          center = [
            # Plasma: Media Controls
            { id = "MediaMini"; }
            {
               id = "Clock"; 
               formatHorizontal = "HH:mm:ss"; 
               formatVertical = "HH
mm
ss"; 
            }
          ];
          right = [
            # Plasma: Netspeed, Disk, Activity, CPU, Mem, Tray, Camera
            { id = "SystemMonitor"; } # Consolidates Disk/CPU/Mem
            { id = "Network"; }       # Replaces Netspeed
            { id = "Tray"; }          # Replaces System Tray & Camera Indicator
            { id = "Battery"; }
            { id = "ControlCenter"; } # Replaces System Tray details
          ];
        };
        screenOverrides = [ ];
      };

      # --- Bottom Dock (Matching Plasma Bottom Panel) ---
      dock = {
        enabled = true;
        position = "bottom";
        displayMode = "auto_hide"; # Matches "hiding: dodge"
        backgroundOpacity = lib.mkForce 0.8;
        floatingRatio = 1;
        size = 1; # Default scaling
        onlySameOutput = true;
        monitors = [ ];
        pinnedApps = [
            # Add commonly used apps here if desired, otherwise it shows running apps
            "kitty"
            "firefox"
            "dolphin"
        ];
        colorizeIcons = false;
        pinnedStatic = false;
        inactiveIndicators = true;
        deadOpacity = 0.6;
        animationSpeed = 1;
      };

      # --- General & Styling ---
      general = {
        avatarImage = "";
        dimmerOpacity = 0.2;
        showScreenCorners = false;
        forceBlackScreenCorners = false;
        scaleRatio = 1;
        radiusRatio = 1; # Full rounded corners
        iRadiusRatio = 1;
        boxRadiusRatio = 1;
        screenRadiusRatio = 1;
        animationSpeed = 1;
        animationDisabled = false;
        compactLockScreen = false;
        lockOnSuspend = true;
        showSessionButtonsOnLockScreen = true;
        showHibernateOnLockScreen = false;
        enableShadows = true;
        shadowDirection = "bottom_right";
        shadowOffsetX = 2;
        shadowOffsetY = 3;
        language = "";
        allowPanelsOnScreenWithoutBar = true;
        showChangelogOnStartup = false;
        telemetryEnabled = false;
        enableLockScreenCountdown = true;
        lockScreenCountdownDuration = 10000;
        autoStartAuth = false;
        allowPasswordWithFprintd = false;
      };

      ui = {
        fontDefault = lib.mkForce "";
        fontFixed = lib.mkForce "";
        fontDefaultScale = 1;
        fontFixedScale = 1;
        tooltipsEnabled = true;
        panelBackgroundOpacity = lib.mkForce 0.93;
        panelsAttachedToBar = true;
        settingsPanelMode = "attached";
        wifiDetailsViewMode = "grid";
        bluetoothDetailsViewMode = "grid";
        networkPanelView = "wifi";
        bluetoothHideUnnamedDevices = false;
        boxBorderEnabled = false;
      };

      # --- Wallpaper (Matching Plasma Limine Images) ---
      wallpaper = {
        enabled = true;
        overviewEnabled = false;
        directory = "/home/ksvnixospc/Documents/ksvnixospcconfigs/nixosModules/nixosResources/limine-images";
        monitorDirectories = [ ];
        enableMultiMonitorDirectories = false;
        showHiddenFiles = false;
        viewMode = "single";
        setWallpaperOnAllMonitors = true;
        fillMode = "crop";
        fillColor = "#000000";
        useSolidColor = false;
        solidColor = "#1a1a2e";
        automationEnabled = true; # Enable slideshow
        wallpaperChangeMode = "random"; # Or "sequential"
        randomIntervalSec = 300; # 5 minutes
        transitionDuration = 1500;
        transitionType = "random";
        transitionEdgeSmoothness = 0.05;
        panelPosition = "follow_bar";
        hideWallpaperFilenames = false;
        useWallhaven = false;
      };

      # --- Control Center ---
      controlCenter = {
        position = "close_to_bar_button";
        diskPath = "/";
        shortcuts = {
          left = [
            { id = "Network"; }
            { id = "Bluetooth"; }
            { id = "WallpaperSelector"; }
            { id = "NoctaliaPerformance"; }
          ];
          right = [
            { id = "Notifications"; }
            { id = "PowerProfile"; }
            { id = "KeepAwake"; }
            { id = "NightLight"; }
          ];
        };
        cards = [
          { enabled = true; id = "profile-card"; }
          { enabled = true; id = "shortcuts-card"; }
          { enabled = true; id = "audio-card"; }
          { enabled = false; id = "brightness-card"; } # Enable if laptop
          { enabled = true; id = "weather-card"; }
          { enabled = true; id = "media-sysmon-card"; }
        ];
      };

      # --- System Monitor (Consolidated Widgets) ---
      systemMonitor = {
        cpuWarningThreshold = 80;
        cpuCriticalThreshold = 90;
        tempWarningThreshold = 80;
        tempCriticalThreshold = 90;
        gpuWarningThreshold = 80;
        gpuCriticalThreshold = 90;
        memWarningThreshold = 80;
        memCriticalThreshold = 90;
        swapWarningThreshold = 80;
        swapCriticalThreshold = 90;
        diskWarningThreshold = 80;
        diskCriticalThreshold = 90;
        cpuPollingInterval = 3000;
        tempPollingInterval = 3000;
        gpuPollingInterval = 3000;
        enableDgpuMonitoring = false;
        memPollingInterval = 3000;
        diskPollingInterval = 30000;
        networkPollingInterval = 3000;
        loadAvgPollingInterval = 3000;
        useCustomColors = false;
        warningColor = "";
        criticalColor = "";
      };

      # --- Network ---
      network = {
        wifiEnabled = true;
        bluetoothRssiPollingEnabled = false;
        bluetoothRssiPollIntervalMs = 10000;
        wifiDetailsViewMode = "grid";
        bluetoothDetailsViewMode = "grid";
        bluetoothHideUnnamedDevices = false;
      };

      # --- App Launcher ---
      appLauncher = {
        enableClipboardHistory = true; # Plasma has clipboard history
        autoPasteClipboard = false;
        enableClipPreview = true;
        clipboardWrapText = true;
        clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
        clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
        position = "center";
        pinnedApps = [ ];
        useApp2Unit = false;
        sortByMostUsed = true;
        terminalCommand = "kitty"; # Plasma config uses kitty
        customLaunchPrefixEnabled = false;
        customLaunchPrefix = "";
        viewMode = "list";
        showCategories = true;
        iconMode = "tabler";
        showIconBackground = false;
        enableSettingsSearch = true;
        enableWindowsSearch = true;
        ignoreMouseInput = false;
      };

      # --- Colors ---
      colorSchemes = {
        useWallpaperColors = true; # Plasma had accentColorFromWallpaper = true
        predefinedScheme = "Noctalia (default)";
        darkMode = true;
        schedulingMode = "off";
        generationMethod = "tonal-spot";
      };
      
      nightLight = {
        enabled = true; # Plasma has NightColor enabled
        forced = false;
        autoSchedule = true;
        nightTemp = "4000";
        dayTemp = "6500";
      };

      # --- Audio ---
      audio = {
        volumeStep = 5;
        volumeOverdrive = false;
        cavaFrameRate = 30;
        visualizerType = "linear";
        preferredPlayer = ""; # Auto-detect
        volumeFeedback = true;
      };

    };
  };
}