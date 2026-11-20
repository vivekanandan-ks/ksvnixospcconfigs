{self, ...}: {
  flake.homeModules.nonDroid.dms-settings = {lib, ...}: {
    programs.dank-material-shell.settings = lib.mapAttrs (_: lib.mkForce) {
      # Version & Base Meta
      configVersion = 7;
      interfaceStyle = "material";
      density = "comfortable";

      # Typography (Sourced from personas)
      fontFamily = self.personas.ksv.font.monospace.name;
      monoFontFamily = self.personas.ksv.font.monospace.name;
      textRenderType = 0;

      # Theming
      currentThemeCategory = "dynamic";
      currentThemeName = "dynamic";
      customThemeFile = "";
      matugenScheme = "scheme-tonal-spot";
      matugenSpec = "";
      runUserMatugenTemplates = true;
      runDmsMatugenTemplates = true;
      widgetBackgroundColor = "surface";
      widgetColorMode = "primary";

      # Visual Effects & Elevation
      blurEnabled = true;
      blurBorderEnabled = true;
      blurLayerOutlineOpacity = 0.1;
      blurredWallpaperLayer = true;
      foregroundLayerTransparency = 0.9;
      popupTransparency = 0.9;
      sectionDividerOpacity = 0.1;
      m3ElevationEnabled = true;
      m3ElevationIntensity = 1;
      m3ElevationOpacity = 0.1;
      modalElevationEnabled = true;
      barElevationEnabled = true;
      popoutElevationEnabled = true;
      enableRippleEffects = true;
      focusRingEnabled = true;
      focusRingWidth = 2;
      radiusMode = "normal";
      radiusStrength = 1;
      mangoLayoutRadiusOverride = 0;

      # Motion & Animations
      animationDuration = 300;
      motionEffect = 1;
      reduceMotion = false;
      springBounce = 0.2;

      # Cursor (Sourced to match system Stylix cursor)
      cursorSettings = {
        dwl = {
          cursorHideTimeout = 0;
        };
        hyprland = {
          hideOnKeyPress = false;
          hideOnTouch = false;
          inactiveTimeout = 0;
        };
        mango = {
          cursorHideTimeout = 0;
        };
        niri = {
          hideAfterInactiveMs = 0;
          hideWhenTyping = false;
        };
        size = 36;
        theme = "Bibata_Ghost";
      };

      # Clock & Locale
      clockFormat = "HH:mm";
      clockDateFormat = "ddd, MMM d";
      firstDayOfWeek = 1;
      showWeekNumber = false;
      useFahrenheit = false;
      useAutoLocation = false;
      windSpeedUnit = "km/h";

      # Audio & Bluetooth
      audioShowStreamDevices = false;
      bluetoothMprisEnabled = true;
      mediaLyricsProviders = [
        "lrclib"
        "netease"
      ];
      weatherProviders = [
        "open-meteo"
      ];

      # Launcher & Dash
      launcherStyle = "spotlight";
      launcherUseOverlayLayer = true;
      dankLauncherV2Size = "compact";
      dankLauncherV2UnloadOnClose = false;
      dankLauncherV2IncludeFilesInAll = false;
      dankLauncherV2IncludeFoldersInAll = false;
      spotlightBarShowModeChips = true;
      rememberLastQuery = true;
      dashTabs = [
        "weather"
        "music"
        "calendar"
      ];
      dashOptions = {
        battery = {
          health = true;
        };
        calendar = {
          weekends = true;
        };
        clock = {
          date = true;
          numbers = true;
          seconds = true;
        };
        disk = {
          io = true;
        };
        media = {
          albumArtBackdrop = true;
          animatedArt = true;
          artStyle = "disc";
          smoothLyrics = true;
        };
        wallpaper = {
          layout = "carousel";
        };
      };

      # Power Menu & Idle Timeouts
      powerMenuGridLayout = true;
      powerMenuFirmwareSetup = true;
      powerMenuActions = [
        "lock"
        "suspend"
        "hibernate"
        "reboot"
        "shutdown"
        "logout"
        "firmware"
        "restart-session"
        "cancel"
      ];
      lockBeforeSuspend = true;
      fadeToDpmsEnabled = true;
      soundLogin = true;
      acMonitorTimeout = 300;
      acLockTimeout = 600;
      acPostLockMonitorTimeout = 30;
      batteryMonitorTimeout = 180;
      batteryLockTimeout = 300;
      batteryPostLockMonitorTimeout = 15;

      # Notifications & OSD
      notificationAnimationDuration = 200;
      notificationPopupShadowEnabled = true;
      notificationShowTimeoutBar = true;
      modalDarkenBackground = true;
      osdAlwaysShowValue = false;
      osdPosition = 1;
      osdVolumeEnabled = true;
      osdMediaPlaybackEnabled = true;
      osdNumLockEnabled = true;
      osdKeyboardLayoutEnabled = true;
      osdInputMethodEnabled = true;
      osdPowerProfileEnabled = true;
      osdWorkspaceEnabled = true;

      # Window Rules & Frame Mode
      floatingWindowSyncGlobal = true;
      floatingWindowTitleBars = true;
      dmsWindowsFloatingSeeded = [
        "org.gnome.World.PikaBackup"
      ];
      frameEnabled = false;
      frameLauncherArcExtender = false;
      frameLauncherEdgeHover = false;
      frameMode = "none";
      muxType = "tmux";
      greeterFollowLockScreen = true;

      # Built-in Plugins & Actions
      builtInPluginSettings = {
        dms_clipboard_search = {
          trigger = "cb";
        };
        dms_power = {
          trigger = "pw";
        };
        dms_qr_generator = {
          trigger = "qrg";
        };
        dms_settings_search = {
          trigger = "?";
        };
      };
      clipboardVisibleEntryActions = [
        "pin"
        "edit"
        "delete"
        "copy"
        "paste"
      ];
      screenPreferences = {
        wallpaper = [
          "all"
        ];
      };
      connectedFrameBarStyleBackups = {};

      # Dock Configs
      dockConfigs = [
        {
          autoHide = true;
          borderColor = "surfaceText";
          borderEnabled = false;
          borderOpacity = 1;
          borderThickness = 1;
          bottomGap = -10;
          editOnRightClick = false;
          enabled = true;
          followInterfaceStyle = true;
          groupByApp = true;
          iconSize = 36;
          id = "dock";
          indicatorStyle = "pill";
          isolateDisplays = true;
          itemSpacing = 4;
          launcherEnabled = true;
          launcherLogoBrightness = 0.5;
          launcherLogoColorOverride = "";
          launcherLogoContrast = 1;
          launcherLogoCustomPath = "";
          launcherLogoMode = "os";
          launcherLogoSizeOffset = 0;
          magnification = true;
          magnificationExpand = true;
          magnificationProfile = "parabolic";
          magnificationScale = 130;
          margin = 8;
          maxVisibleApps = 0;
          maxVisibleRunningApps = 0;
          middleClickAction = "launch";
          mode = "compact";
          name = "Right Dock";
          openOnOverview = false;
          order = [];
          position = 3;
          restoreSpecialWorkspaceOnClick = false;
          screenPreferences = [
            "all"
          ];
          separatePinnedAndRunningApps = true;
          showOnFullscreen = false;
          showOnLastDisplay = true;
          showOverflowBadge = true;
          showTrash = true;
          smartAutoHide = false;
          spacing = 0;
          taskbarAlign = "center";
          transparency = 1;
          trashCustomCommand = "";
          trashFileManager = "default";
          useOverlayLayer = false;
          widgetExpansion = "popout";
          widgets = [
            {
              enabled = true;
              id = "dock_launcher";
              widgetId = "dockLauncher";
            }
            {
              appsDockColorizeActive = true;
              enabled = true;
              id = "dock_apps";
              widgetId = "appsDock";
            }
            {
              enabled = true;
              id = "dock_trash";
              widgetId = "dockTrash";
            }
          ];
        }
      ];

      # Desktop, Greeter, and Lock Screen Widget Instances
      desktopWidgetInstances = [
        {
          config = {
            alignment = "left";
            backgroundOpacity = 0;
            bodyFontFamily = "Gochi Hand";
            bodyFontSize = 25;
            dateLetterSpacing = 3;
            dayFontFamily = "Gochi Hand";
            dayFontSize = 40;
            dayLetterSpacing = 6;
            displayPreferences = [
              "all"
            ];
            scaleWithWidget = false;
            shadowStrength = 50;
            showDate = true;
            showSeconds = false;
            showTime = false;
            syncPositionAcrossScreens = true;
            timeLetterSpacing = 3;
            use24Hour = true;
            useThemeColors = true;
          };
          enabled = true;
          id = "dw_modern_clock";
          name = "Modern Clock";
          widgetType = "modernClock";
        }
        {
          config = {
            borderOpacity = 0;
            displayPreferences = [
              "all"
            ];
            fontSize = 22;
            showOnOverlay = false;
            syncPositionAcrossScreens = true;
          };
          enabled = true;
          id = "dw_desktop_lyrics";
          name = "Desktop Lyrics";
          widgetType = "desktopLyrics";
        }
        {
          config = {
            displayPreferences = [
              "all"
            ];
            syncPositionAcrossScreens = true;
          };
          enabled = true;
          id = "dw_orbit_bluetooth";
          name = "Orbit Bluetooth";
          widgetType = "orbitBluetooth";
        }
        {
          config = {
            displayPreferences = [
              "all"
            ];
            syncPositionAcrossScreens = true;
          };
          enabled = true;
          id = "dw_abyss";
          name = "Abyss";
          widgetType = "abyss";
        }
        {
          config = {
            displayPreferences = [
              "all"
            ];
            syncPositionAcrossScreens = true;
          };
          enabled = true;
          id = "dw_sticky_notes";
          name = "Sticky Notes";
          widgetType = "stickyNotes";
        }
        {
          config = {
            colorMode = "primary";
            customColor = "#ffffff";
            displayPreferences = [
              "all"
            ];
            fontFamily = "";
            showAnalogNumbers = false;
            showAnalogSeconds = true;
            showDate = true;
            style = "overlap";
            syncPositionAcrossScreens = true;
            transparency = 0;
            weight = 900;
          };
          enabled = true;
          id = "dw_1793825465292_7h0wdwsa2";
          name = "Clock";
          widgetType = "desktopClock";
        }
      ];

      greeterWidgetInstances = [
        {
          config = {
            autoPosition = false;
            colorMode = "default";
            customColor = "#ffffff";
            displayPreferences = [
              "all"
            ];
            showAnalogNumbers = false;
            showAnalogSeconds = true;
            showDate = true;
            showDigitalSeconds = true;
            style = "overlap";
            syncPositionAcrossScreens = true;
            transparency = 0;
            twoTone = true;
            weight = 0;
          };
          enabled = true;
          id = "lock_clock";
          widgetType = "desktopClock";
        }
        {
          config = {
            colorMode = "default";
            customColor = "#ffffff";
            displayPreferences = [
              "all"
            ];
            format = "short";
            syncPositionAcrossScreens = true;
          };
          enabled = false;
          id = "lock_date";
          widgetType = "lockDate";
        }
        {
          config = {
            displayPreferences = [
              "all"
            ];
            passwordVisibility = "always";
            profileVisibility = "always";
            style = "expressive";
            syncPositionAcrossScreens = true;
          };
          enabled = true;
          id = "lock_auth";
          widgetType = "lockAuth";
        }
        {
          config = {
            background = false;
            displayPreferences = [
              "all"
            ];
            showMediaPlayer = false;
            showWeather = true;
            syncPositionAcrossScreens = true;
          };
          enabled = true;
          id = "lock_status";
          widgetType = "lockStatus";
        }
        {
          config = {
            displayPreferences = [
              "all"
            ];
            shape = "round";
            syncPositionAcrossScreens = true;
          };
          enabled = false;
          id = "lock_power";
          widgetType = "lockPower";
        }
        {
          config = {
            displayPreferences = [
              "all"
            ];
            shape = "round";
            syncPositionAcrossScreens = true;
          };
          enabled = true;
          id = "lw_1792586348135_6mvng5dmo";
          name = "Power";
          widgetType = "lockPower";
        }
        {
          config = {
            displayPreferences = [
              "all"
            ];
            syncPositionAcrossScreens = true;
          };
          enabled = true;
          id = "greeter_session";
          widgetType = "greeterSession";
        }
        {
          config = {
            colorMode = "secondary";
            customColor = "#ffffff";
            displayPreferences = [
              "all"
            ];
            format = "long";
            syncPositionAcrossScreens = true;
          };
          enabled = true;
          id = "gw_1793862806299_dvk5d3xxz";
          name = "Date";
          widgetType = "lockDate";
        }
      ];

      lockScreenWidgetInstances = [
        {
          config = {
            autoPosition = false;
            colorMode = "default";
            customColor = "#ffffff";
            displayPreferences = [
              "all"
            ];
            showAnalogNumbers = false;
            showAnalogSeconds = true;
            showDate = true;
            showDigitalSeconds = true;
            style = "overlap";
            syncPositionAcrossScreens = true;
            transparency = 0;
            twoTone = true;
            weight = 0;
          };
          enabled = true;
          id = "lock_clock";
          widgetType = "desktopClock";
        }
        {
          config = {
            colorMode = "default";
            customColor = "#ffffff";
            displayPreferences = [
              "all"
            ];
            format = "short";
            syncPositionAcrossScreens = true;
          };
          enabled = false;
          id = "lock_date";
          widgetType = "lockDate";
        }
        {
          config = {
            displayPreferences = [
              "all"
            ];
            passwordVisibility = "always";
            profileVisibility = "always";
            style = "expressive";
            syncPositionAcrossScreens = true;
          };
          enabled = true;
          id = "lock_auth";
          widgetType = "lockAuth";
        }
        {
          config = {
            displayPreferences = [
              "all"
            ];
            mode = 1;
            syncPositionAcrossScreens = true;
          };
          enabled = true;
          id = "lock_notifications";
          widgetType = "lockNotifications";
        }
        {
          config = {
            background = false;
            displayPreferences = [
              "all"
            ];
            showMediaPlayer = true;
            showWeather = true;
            syncPositionAcrossScreens = true;
          };
          enabled = true;
          id = "lock_status";
          widgetType = "lockStatus";
        }
        {
          config = {
            displayPreferences = [
              "all"
            ];
            shape = "round";
            syncPositionAcrossScreens = true;
          };
          enabled = false;
          id = "lock_power";
          widgetType = "lockPower";
        }
        {
          config = {
            displayPreferences = [
              "all"
            ];
            shape = "round";
            syncPositionAcrossScreens = true;
          };
          enabled = true;
          id = "lw_1792586348135_6mvng5dmo";
          name = "Power";
          widgetType = "lockPower";
        }
        {
          config = {
            displayPreferences = [
              "all"
            ];
            syncPositionAcrossScreens = true;
          };
          enabled = true;
          id = "lw_1792586458852_0c7pra8xg";
          name = "Desktop Lyrics";
          widgetType = "desktopLyrics";
        }
        {
          config = {
            alignment = "center";
            bodyFontFamily = "Gochi Hand";
            bodyFontSize = 25;
            dateLetterSpacing = 2;
            dayFontFamily = "Gochi Hand";
            dayFontSize = 50;
            dayLetterSpacing = 9;
            displayPreferences = [
              "all"
            ];
            scaleWithWidget = false;
            showSeconds = false;
            showTime = false;
            syncPositionAcrossScreens = true;
            use24Hour = true;
            useThemeColors = true;
          };
          enabled = true;
          id = "lw_1793826474805_4vtp5yych";
          name = "Modern Clock";
          widgetType = "modernClock";
        }
      ];
    };
  };
}
