_: {
  flake.homeModules.nonDroid.dms-settings = {lib, ...}: {
    programs.dank-material-shell.settings = lib.mapAttrs (_: lib.mkForce) {
      acLockTimeout = 300;
      acMonitorTimeout = 300;
      acPostLockMonitorTimeout = 60;
      animationDuration = 750;
      audioShowStreamDevices = true;
      barElevationEnabled = false;
      batteryLockTimeout = 180;
      batteryMonitorTimeout = 180;
      batteryPostLockMonitorTimeout = 60;
      bluetoothMprisEnabled = true;
      blurBorderEnabled = false;
      blurEnabled = false;
      blurLayerOutlineOpacity = 0;
      blurredWallpaperLayer = false;
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
      clipboardVisibleEntryActions = ["pin" "edit" "delete" "copy" "paste"];
      clockDateFormat = "ddd MMM d";
      clockFormat = "24h";
      configVersion = 42;
      connectedFrameBarStyleBackups = {};
      currentThemeCategory = "dynamic";
      currentThemeName = "dynamic";
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
        size = 24;
        theme = "Bibata_Spirit";
      };
      customThemeFile = "";
      dankLauncherV2IncludeFilesInAll = true;
      dankLauncherV2IncludeFoldersInAll = true;
      dankLauncherV2Size = "micro";
      dankLauncherV2UnloadOnClose = true;
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
      dashTabs = [
        {
          enabled = true;
          id = "overview";
        }
        {
          enabled = true;
          id = "media";
        }
        {
          enabled = true;
          id = "weather";
        }
        {
          enabled = true;
          id = "wallpaper";
        }
        {
          enabled = true;
          id = "wellbeing";
        }
        {
          enabled = true;
          id = "settings";
        }
        {
          enabled = true;
          id = "notifications";
        }
      ];
      density = "dense";
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
            displayPreferences = ["all"];
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
            displayPreferences = ["all"];
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
            displayPreferences = ["all"];
            syncPositionAcrossScreens = true;
          };
          enabled = true;
          id = "dw_orbit_bluetooth";
          name = "Orbit Bluetooth";
          widgetType = "orbitBluetooth";
        }
        {
          config = {
            displayPreferences = ["all"];
            syncPositionAcrossScreens = true;
          };
          enabled = true;
          id = "dw_abyss";
          name = "Abyss";
          widgetType = "abyss";
        }
        {
          config = {
            colorMode = "primary";
            customColor = "#ffffff";
            displayPreferences = ["all"];
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
      dmsWindowsFloatingSeeded = ["mango"];
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
          screenPreferences = ["all"];
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
      enableRippleEffects = true;
      fadeToDpmsEnabled = false;
      fadeToLockEnabled = false;
      firstDayOfWeek = 1;
      floatingWindowSyncGlobal = true;
      floatingWindowTitleBars = true;
      focusRingEnabled = true;
      focusRingWidth = 1.5;
      fontFamily = "DejaVu Sans";
      foregroundLayerTransparency = 0.7;
      frameEnabled = false;
      frameLauncherArcExtender = false;
      frameLauncherEdgeHover = true;
      frameMode = "connected";
      greeterFollowLockScreen = false;
      greeterWidgetInstances = [
        {
          config = {
            autoPosition = false;
            colorMode = "default";
            customColor = "#ffffff";
            displayPreferences = ["all"];
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
            displayPreferences = ["all"];
            format = "short";
            syncPositionAcrossScreens = true;
          };
          enabled = false;
          id = "lock_date";
          widgetType = "lockDate";
        }
        {
          config = {
            displayPreferences = ["all"];
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
            displayPreferences = ["all"];
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
            displayPreferences = ["all"];
            shape = "round";
            syncPositionAcrossScreens = true;
          };
          enabled = false;
          id = "lock_power";
          widgetType = "lockPower";
        }
        {
          config = {
            displayPreferences = ["all"];
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
            displayPreferences = ["all"];
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
            displayPreferences = ["all"];
            format = "long";
            syncPositionAcrossScreens = true;
          };
          enabled = true;
          id = "gw_1793862806299_dvk5d3xxz";
          name = "Date";
          widgetType = "lockDate";
        }
      ];
      interfaceStyle = "expressive";
      launcherStyle = "full";
      launcherUseOverlayLayer = true;
      lockBeforeSuspend = true;
      lockScreenWidgetInstances = [
        {
          config = {
            autoPosition = false;
            colorMode = "default";
            customColor = "#ffffff";
            displayPreferences = ["all"];
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
            displayPreferences = ["all"];
            format = "short";
            syncPositionAcrossScreens = true;
          };
          enabled = false;
          id = "lock_date";
          widgetType = "lockDate";
        }
        {
          config = {
            displayPreferences = ["all"];
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
            displayPreferences = ["all"];
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
            displayPreferences = ["all"];
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
            displayPreferences = ["all"];
            shape = "round";
            syncPositionAcrossScreens = true;
          };
          enabled = false;
          id = "lock_power";
          widgetType = "lockPower";
        }
        {
          config = {
            displayPreferences = ["all"];
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
            displayPreferences = ["all"];
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
            displayPreferences = ["all"];
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
        {
          config = {
            displayPreferences = ["all"];
            syncPositionAcrossScreens = true;
          };
          enabled = true;
          id = "lw_nostr_unlock";
          name = "Nostr Unlock";
          widgetType = "nostrUnlock";
        }
      ];
      m3ElevationEnabled = false;
      m3ElevationIntensity = 0;
      m3ElevationOpacity = 0;
      mangoLayoutRadiusOverride = -1;
      matugenScheme = "scheme-tonal-spot";
      matugenSpec = "dms";
      mediaLyricsProviders = [
        {
          enabled = true;
          id = "betterlyrics";
        }
        {
          enabled = true;
          id = "unison";
        }
        {
          enabled = true;
          id = "lyricsplus";
        }
        {
          enabled = true;
          id = "kugou";
        }
        {
          enabled = true;
          id = "lrclib";
        }
        {
          enabled = true;
          id = "youtubemusic";
        }
      ];
      modalDarkenBackground = false;
      modalElevationEnabled = false;
      monoFontFamily = "DejaVu Sans Mono";
      motionEffect = 1;
      muxType = "zellij";
      notificationAnimationDuration = 400;
      notificationPopupShadowEnabled = false;
      notificationShowTimeoutBar = true;
      osdAlwaysShowValue = true;
      osdInputMethodEnabled = true;
      osdKeyboardLayoutEnabled = true;
      osdMediaPlaybackEnabled = true;
      osdNumLockEnabled = true;
      osdPosition = 0;
      osdPowerProfileEnabled = true;
      osdVolumeEnabled = true;
      osdWorkspaceEnabled = true;
      popoutElevationEnabled = false;
      popupTransparency = 0.5;
      powerMenuActions = ["reboot" "logout" "poweroff" "lock" "suspend" "restart" "switchuser" "hibernate" "softreboot"];
      powerMenuFirmwareSetup = true;
      powerMenuGridLayout = true;
      radiusMode = "scale";
      radiusStrength = 50;
      reduceMotion = false;
      rememberLastQuery = true;
      runDmsMatugenTemplates = false;
      runUserMatugenTemplates = false;
      screenPreferences = {
        wallpaper = ["all"];
      };
      sectionDividerOpacity = 0.1;
      showWeekNumber = true;
      soundLogin = true;
      spotlightBarShowModeChips = true;
      springBounce = 1;
      textRenderType = 0;
      useAutoLocation = true;
      useFahrenheit = false;
      weatherProviders = [
        {
          enabled = true;
          id = "openmeteo";
        }
        {
          enabled = true;
          id = "metno";
        }
      ];
      widgetBackgroundColor = "sc";
      widgetColorMode = "default";
      windSpeedUnit = "ms";
    };
  };
}
