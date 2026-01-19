{
  #inputs,
  #config,
  lib,
  #pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages = with pkgs-unstable; [
    plasmusic-toolbar
    plasma-panel-colorizer
    plasma-plugin-blurredwallpaper
  ];

  programs.plasma = {
    #enable = true;

    configFile = {
      "kwinrc" = {
        "ElectricBorders" = {
          "TopLeft" = "Overview";
          "BottomRight" = "ShowDesktop";
          "BottomLeft" = "Grid";
        };
        "Effect-blur" = {
          BlurStrength = 5;
          NoiseStrength = 8;
        };
        "Effect-blurplus" = {
          BlurDecorations = true;
          BlurMenus = true;
          BlurStrength = 8;
          FakeBlur = true;
          NoiseStrength = 0;
          TransparentBlur = false;
        };
        "Effect-cube" = {
          SkyBox = "/home/ksvnixospc/Pictures/Anime wallpapers/demon-slayer-3840x2160-17927.jpg";
        };
        "Effect-diminactive" = {
          Strength = 20;
        };
        "Effect-hidecursor" = {
          HideOnTyping = true;
        };
        "Effect-magiclamp" = {
          AnimationDuration = 400;
        };
        "Effect-thumbnailaside" = {
          Opacity = 100;
        };
        "Effect-translucency" = {
          MoveResize = 82;
        };
        "Effect-zoom" = {
          MouseTracking = 1;
        };
        "NightColor" = {
          Active = true;
          Mode = "Constant";
        };
        "Plugins" = {
          blurEnabled = true;
          cubeEnabled = true;
          desktopchangeosdEnabled = true;
          diminactiveEnabled = true;
          dimscreenEnabled = true;
          fadeEnabled = true;
          fadedesktopEnabled = true;
          forceblurEnabled = true;
          glideEnabled = false;
          hidecursorEnabled = true;
          kwin4_effect_geometry_changeEnabled = true;
          kzonesEnabled = true;
          magiclampEnabled = true;
          mousemarkEnabled = true;
          scaleEnabled = false;
          shakecursorEnabled = true;
          sheetEnabled = true;
          slideEnabled = true;
          snaphelperEnabled = true;
          squashEnabled = false;
          thumbnailasideEnabled = true;
          translucencyEnabled = true;
          videowallEnabled = true;
          wobblywindowsEnabled = true;
        };
        "Round-Corners" = {
          InactiveCornerRadius = 18;
          Size = 18;
        };
        "Tiling" = {
          padding = 4;
        };
        "Windows" = {
          RollOverDesktops = true;
        };
        "Xwayland" = {
          Scale = 1;
        };
        "org.kde.kdecoration2" = {
          ButtonsOnLeft = "SF";
          ButtonsOnRight = "HIAX";
        };
      };
      "kdeglobals" = {
        General = {
          TerminalApplication = "kitty";
          AccentColor = "162,58,207";
          accentColorFromWallpaper = true;
        };
        Icons = {
          Theme = "candy-icons";
        };
        KDE = {
          AnimationDurationFactor = 0.17677669529663687;
          ShowDeleteCommand = true;
        };
        "KFileDialog Settings" = {
          "Allow Expansion" = false;
          "Automatically select filename extension" = true;
          "Breadcrumb Navigation" = true;
          "Decoration position" = 2;
          "Show Full Path" = false;
          "Show Inline Previews" = true;
          "Show Preview" = false;
          "Show Speedbar" = true;
          "Show hidden files" = false;
          "Sort by" = "Name";
          "Sort directories first" = true;
          "Sort hidden files last" = false;
          "Sort reversed" = false;
          "Speedbar Width" = 140;
          "View Style" = "Simple";
        };
        PreviewSettings = {
          EnableRemoteFolderThumbnail = false;
          MaximumRemoteSize = 0;
        };
        Sounds = {
          Theme = "freedesktop";
        };
        WM = {
          activeBackground = "30,30,46";
          activeBlend = "249,226,175";
          activeForeground = "205,214,244";
          inactiveBackground = "30,30,46";
          inactiveBlend = "69,71,90";
          inactiveForeground = "205,214,244";
        };
      };
      "dolphinrc" = {
        ContentDisplay = {
          UsePermissionsFormat = "CombinedFormat";
          UseShortRelativeDates = false;
        };
        ContextMenu = {
          ShowCopyMoveMenu = true;
        };
        General = {
          DoubleClickViewAction = "none";
          FilterBar = true;
          ShowFullPath = true;
          ShowFullPathInTitlebar = true;
          ShowStatusBar = "FullWidth";
        };
        IconsMode = {
          MaximumTextLines = 4;
        };
        "KFileDialog Settings" = {
          "Places Icons Auto-resize" = false;
          "Places Icons Static Size" = 22;
        };
        PreviewSettings = {
          Plugins = "appimagethumbnail,audiothumbnail,blenderthumbnail,comicbookthumbnail,cursorthumbnail,djvuthumbnail,ebookthumbnail,exrthumbnail,directorythumbnail,fontthumbnail,imagethumbnail,jpegthumbnail,kraorathumbnail,windowsexethumbnail,windowsimagethumbnail,mobithumbnail,opendocumentthumbnail,gsthumbnail,rawthumbnail,svgthumbnail,ffmpegthumbs";
        };
        Search = {
          Location = "Everywhere";
        };
        VersionControl = {
          enabledPlugins = "Git";
        };
      };
      "kscreenlockerrc" = {
        Daemon = {
          LockGrace = 900;
        };
        Greeter = {
          WallpaperPlugin = "org.kde.slideshow";
        };
        "Greeter/LnF/General" = {
          alwaysShowClock = true;
          showMediaControls = true;
        };
      };
      "kcminputrc" = {
        Keyboard = {
          NumLock = 0;
        };
      };
      "krunnerrc" = {
        General = {
          historyBehavior = "ImmediateCompletion";
        };
        Plugins = {
          krunner_keysEnabled = true;
        };
        "Plugins/Favorites" = {
          plugins = "krunner_sessions,krunner_powerdevil,krunner_services,krunner_systemsettings,krunner_dictionary";
        };
      };
      "kwalletrc" = {
        Wallet = {
          "First Use" = false;
        };
      };
      "spectaclerc" = {
        Annotations = {
          textFontColor = "255,255,255";
          textShadow = false;
        };
        ImageSave = {
          translatedScreenshotsFolder = "Screenshots";
        };
        VideoSave = {
          translatedScreencastsFolder = "Screencasts";
        };
      };
    };

    workspace = {
      #wallpaperSlideShow = /*lib.filesystem.listFilesRecursive*/ ./../nixosModules/nixosResources/limine-images;
      wallpaperSlideShow = {
        path = ./../nixosModules/nixosResources/limine-images;
        interval = 300; # default: 300
      };
      #wallpaper = lib.filesystem.listFilesRecursive ./../nixosModules/nixosResources/limine-images;
      wallpaperBackground.blur = true;

      # cursor
      cursor = {
        animationTime = 5;
        cursorFeedback = "Bouncing";
        #size = 24;
        taskManagerFeedback = true;
        #theme = "Breeze_Snow";
        #theme = "breeze_cursors";
      };
    };

    desktop = {
      icons = {
        alignment = "left";
        arrangement = "topToBottom";
        #folderPreviewPopups = true; # defauly: true
        previewPlugins = [
          "audiothumbnail"
          "fontthumbnail"
        ];
      };
      widgets = [
        /*
        {
          config = {
            Appearance = {
              showDate = true;
            };
          };
          name = "org.kde.plasma.digitalclock";
          position = {
            horizontal = 51;
            vertical = 100;
          };
          size = {
            height = 250;
            width = 250;
          };
        }
        */
      ];
    };

    kscreenlocker = {
      appearance = {
        alwaysShowClock = true;
        showMediaControls = true;
        wallpaperSlideShow = {
          path = ./../nixosModules/nixosResources/limine-images;
          interval = 300; # default: 300
        };
      };
      #autoLock = true;
      #timeout = 2; # minutes
      lockOnResume = true;
      passwordRequired = true;
    };

    kwin = {
      effects = {
        blur = {
          enable = true;
          #noiseStrength = 8;
          #strength = 5;
        };
        cube.enable = true;
        desktopSwitching.animation = "slide";
        desktopSwitching.navigationWrapping = true;
        dimAdminMode.enable = true;
        dimInactive.enable = true;
        minimization.animation = "magiclamp"; # Type: null or one of “squash”, “magiclamp”, “off”
        #minimization.duration = 50; # milliseconds
        shakeCursor.enable = true;
        hideCursor = {
          enable = true;
          hideOnTyping = true;
        };
        snapHelper.enable = true;
        translucency.enable = true;
        wobblyWindows.enable = true;
        windowOpenClose.animation = "fade"; # Type: null or one of “fade”, “glide”, “scale”, “off”
      };
      nightLight = {
        enable = true;
        mode = "constant";
      };
      titlebarButtons = {
        left = [
          "on-all-desktops"
          "keep-above-windows"
        ];
        right = [
          "help"
          "minimize"
          "maximize"
          "close"
        ];
      };
      virtualDesktops = {
        names = [
          "D1"
          "D2"
          "D3"
          "D4"
        ];
        number = 4;
        rows = 2;
      };
    };
    session.general.askForConfirmationOnLogout = true;

    /*
    hotkeys.commands = {
    "launch-kitty" = {
      name = "Launch Kitty";
      key = "Meta+Alt+K";
      command = "kitty";
    };
    */

    # powerdevil and panel settings are pending
    # panel to be decided whether to go kde way or waybar like way
    powerdevil = {
      general = {
        pausePlayersOnSuspend = true;
      };

      AC = {
        powerProfile = "performance";
        displayBrightness = 30;
        powerButtonAction = "shutDown";

        dimDisplay = {
          enable = true;
          idleTimeout = 300; # 5 minutes
        };

        turnOffDisplay = {
          idleTimeout = 600; # 10 minutes
          idleTimeoutWhenLocked = 60; # 1 minute
        };

        autoSuspend = {
          action = "nothing";
        };

        whenLaptopLidClosed = "doNothing";
      };

      battery = {
        powerProfile = "powerSaving";
        displayBrightness = 20;
        powerButtonAction = "shutDown";

        dimDisplay = {
          enable = true;
          idleTimeout = 300; # 5 minutes
        };

        turnOffDisplay = {
          idleTimeout = 600; # 10 minutes
          idleTimeoutWhenLocked = 60; # 1 minute
        };

        autoSuspend = {
          action = "nothing";
        };

        whenLaptopLidClosed = "doNothing";
      };

      lowBattery = {
        powerProfile = "powerSaving";
        displayBrightness = 20;
        powerButtonAction = "shutDown";

        dimDisplay = {
          enable = true;
          idleTimeout = 300; # 5 minutes
        };

        turnOffDisplay = {
          idleTimeout = 600; # 10 minutes
          idleTimeoutWhenLocked = 60; # 1 minute
        };

        autoSuspend = {
          action = "nothing";
          #action = "shutDown";
          #idleTimeout = 300; # 5 minutes
        };

        whenLaptopLidClosed = "doNothing";
      };
    };

    session = {
      sessionRestore.restoreOpenApplicationsOnLogin = "startWithEmptySession";
    };

    panels = [
      # top panel
      {
        location = "top";
        height = 30;
        floating = true;
        lengthMode = "fit"; # "fill";
        hiding = "none"; # "Always visible"
        screen = "all";
        opacity = "translucent";

        widgets = [
          # 1. Window Title
          {
            name = "org.kde.plasma.windowtitle";
          }
          # 2. Global Menu
          {
            appmenu = {};
          }
          # 3. Panel Spacer
          {
            panelSpacer = {
              #expanding = true;

              expanding = false;
              length = 0;
            };
          }
          # 4. Pager
          {
            pager = {};
          }
          # 5. Icons-Only Task Manager
          {
            iconTasks = {
              appearance = {
                showTooltips = true;
              };
            };
          }
          # 6. PlasMusic Toolbar (Custom Widget)
          {
            name = "plasmusic-toolbar";
            config = {
              General = {
                albumCoverRadius = 6;
                artistsPosition = 2;
                fullViewTextScrollingSpeed = 1;
                maxSongWidthInPanel = 75;
                panelBackgroundRadius = 0;
                panelControlsSizeRatio = 1;
                panelIconSizeRatio = 1;
                pauseTextScrollingWhileMediaIsNotPlaying = true;
                preferredPlayerIdentity = "Metro - realme narzo 30A";
                songTextAlignment = 132;
                textScrollingResetOnPause = true;
                textScrollingSpeed = 1;
                useAlbumCoverAsPanelIcon = true;
              };
            };
          }
          # 7. Panel Spacer
          {
            panelSpacer = {
              #expanding = true;

              expanding = false;
              length = 0;
            };
          }
          # 8. Netspeed Widget (Custom)
          {
            name = "org.kde.netspeedWidget";
            config = {
              General = {
                fontSize = 150;
                showLowSpeeds = true;
                speedLayout = "columns";
              };
            };
          }
          # 9. Disk Usage
          {
            name = "org.kde.plasma.systemmonitor.diskusage";
            config = {
              Appearance = {
                chartFace = "org.kde.ksysguard.horizontalbars";
                title = "Disk Usage";
              };
            };
          }
          # 10. Hard Disk Activity
          {
            name = "org.kde.plasma.systemmonitor.diskactivity";
            config = {
              Appearance = {
                chartFace = "org.kde.ksysguard.piechart";
                title = "Hard Disk Activity";
              };
            };
          }
          # 11. CatWalk (Custom)
          {
            name = "org.kde.plasma.catwalk";
            config = {
              General = {
                idle = 30;
                updateRateLimit = 500;
              };
            };
          }
          # 12. Individual Core Usage
          {
            name = "org.kde.plasma.systemmonitor.cpucore";
            config = {
              Appearance = {
                chartFace = "org.kde.ksysguard.barchart";
                title = "Individual Core Usage";
              };
            };
          }
          # 13. Memory Usage
          {
            name = "org.kde.plasma.systemmonitor.memory";
            config = {
              Appearance = {
                chartFace = "org.kde.ksysguard.piechart";
                title = "Memory Usage";
              };
            };
          }
          # 14. Margins Separator
          {
            name = "org.kde.plasma.marginsseparator";
          }
          # 15. Camera Indicator
          {
            name = "org.kde.plasma.cameraindicator";
          }
          # 16. System Tray
          {
            systemTray = {};
          }
          # 17. Digital Clock
          {
            digitalClock = {
              date = {
                enable = false;
              };
              time = {
                format = "24h";
                showSeconds = "always";
              };
            };
          }
          # 18. Panel Colorizer
          {
            name = "luisbocanegra.panel.colorizer";
            config = {
              General = {
                hideWidget = true;
              };
            };
          }
        ];
      }

      # bottom panel
      {
        location = "bottom";
        height = 42;
        floating = true;
        alignment = "center";
        lengthMode = "fit";
        hiding = "dodge"; # "Windows Go Below" usually maps to dodge windows
        screen = "all";
        opacity = "translucent";

        widgets = [
          # 1. Application Dashboard
          {
            name = "org.kde.plasma.kickerdash";
            config = {
              General = {
                alphaSort = true;
                enableGlow = true;
                favoriteSystemActions = "lock-screen,suspend,hibernate,logout,shutdown,reboot";
                icon = "nix-snowflake";
              };
            };
          }
          # 2. Icons-Only Task Manager
          {
            iconTasks = {
              appearance = {
                showTooltips = true;
                indicateAudioStreams = true;
                fill = true;
              };
            };
          }
          # 3. Margins Separator
          {
            name = "org.kde.plasma.marginsseparator";
          }
          # 4. Peek at Desktop
          {
            name = "org.kde.plasma.showdesktop";
          }
          # 5. Panel Colorizer
          {
            name = "luisbocanegra.panel.colorizer";
            config = {
              General = {
                hideWidget = true;
              };
            };
          }
        ];
      }
    ];
  };
}
