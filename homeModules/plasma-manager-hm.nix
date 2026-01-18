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

    configFile."kwinrc" = {
      #Effect-overview.BorderActivate = 9;
      "ElectricBorders" = {
        # Corner/Edge mappings:
        # TopLeft, Top, TopRight, Right, BottomRight, Bottom, BottomLeft, Left

        # Example: Top-Left corner triggers "Overview"
        "TopLeft" = "Overview";

        # Example: Bottom-Right corner triggers "Show Desktop"
        "BottomRight" = "ShowDesktop"; #Peek at Desktop

        "BottomLeft" = "Grid";

        # Example: Right edge triggers "KRunner"
        #"Right" = "KRunner";
      };
    };

    configFile.kdeglobals = {
      General = {
        TerminalApplication = "kitty";
        #TerminalService = "com.mitchellh.ghostty.desktop";
      };
      KDE.AnimationDurationFactor = 0.17677669529663687;

      /*
        "KFileDialog Settings" = {
        "Allow Expansion" = false;
        "Automatically select filename extension" = true;
        "Breadcrumb Navigation" = false;
        "Decoration position" = 2;
        "Show Full Path" = true;
        "Show Inline Previews" = true;
        "Show Preview" = true;
        "Show Speedbar" = true;
        "Show hidden files" = true;
        "Sort by" = "Date";
        "Sort directories first" = true;
        "Sort hidden files last" = false;
        "Sort reversed" = false;
        "Speedbar Width" = 140;
        "View Style" = "DetailTree";
      };
      */

      /*
        Shortcuts = {
        Copy = "Ctrl+C; Meta+C; Ctrl+Ins";
        CreateFolder = "Meta+Shift+N; Ctrl+Shift+N";
        Cut = "Ctrl+X; Meta+X";
        New = "Ctrl+N; Meta+N";
        Paste = "Ctrl+V; Shift+Ins; Meta+V";
        Preferences = "Meta+,";
        Save = "Ctrl+S; Meta+S";
        SaveAs = "Ctrl+Shift+S; Meta+Shift+S";
      };
      */
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
        desktopSwitching.animation = "fade";
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
        whenPowerButtonIsPressed = "shutDown";

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
        whenPowerButtonIsPressed = "shutDown";

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
        whenPowerButtonIsPressed = "shutDown";

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
              expanding = true;

              #expanding = false;
              #length = 0;
            };
          }
          # 4. Pager
          {
            pager = {};
          }
          # 5. PlasMusic Toolbar (Custom Widget)
          {
            name = "plasmusic-toolbar";
            config = {
              General = {
                # You can add specific config keys here if needed
                # viewType = "panel";
              };
            };
          }
          # 6. Icons-Only Task Manager
          {
            iconTasks = {
              appearance = {
                showTooltips = true;
              };
              #launchers = []; # Top panel didn't show pinned launchers in the video
            };
          }
          # 7. Panel Spacer
          {
            panelSpacer = {
              expanding = true;

              #expanding = false;
              #length = 0;
            };
          }
          # 8. Netspeed Widget (Custom)
          {
            name = "org.kde.netspeedWidget"; # https://github.com/dfaust/plasma-applet-netspeed-widget
          }
          # 9. Disk Usage (Custom)
          {
            name = "org.kde.plasma.diskquota"; # Common ID, verify if different
          }
          # 10. Hard Disk Activity (Likely System Monitor Sensor)
          {
            systemMonitor = {
              title = "Hard Disk Activity";
              # Specific sensor config would go here
            };
          }
          # 11. CatWalk (Custom)
          {
            name = "com.github.k_donn.catwalk";
          }
          # 12. Individual Core Usage (System Monitor)
          {
            systemMonitor = {
              title = "Core Usage";
              displayStyle = "org.kde.ksysguard.barcluster";
            };
          }
          # 13. Memory Usage (System Monitor)
          {
            systemMonitor = {
              title = "Memory Usage";
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
                format = "isoDate";
              };
              time = {
                format = "24h";
              };
            };
          }
          # 18. Peek at Desktop (Show Desktop)
          {
            name = "org.kde.plasma.showdesktop";
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
            kickoff = {
              icon = "nix-snowflake";
              # The video tooltip says "Application Dashboard", which is technically
              # a different widget than Kickoff, but plasma-manager often maps them similarly.
              # If this renders the standard menu, replace `kickoff` with:
              # name = "org.kde.plasma.kickerdash";
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
        ];
      }
    ];
  };
}
