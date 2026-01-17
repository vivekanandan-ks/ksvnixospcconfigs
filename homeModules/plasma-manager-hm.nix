{
  #inputs,
  #config,
  lib,
  #pkgs,
  #pkgs-unstable,
  ...
}: {
  programs.plasma = {
    #enable = true;

    configFile."kwinrc" = {
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

    workspace = {
      #wallpaperSlideShow = /*lib.filesystem.listFilesRecursive*/ ./../nixosModules/nixosResources/limine-images;
      wallpaperSlideShow = {
        path = lib.filesystem.listFilesRecursive ./../nixosModules/nixosResources/limine-images;
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
      ];
    };

    kscreenlocker = {
      appearance = {
        alwaysShowClock = true;
        showMediaControls = true;
        wallpaperSlideShow = {
          path = lib.filesystem.listFilesRecursive ./../nixosModules/nixosResources/limine-images;
          interval = 300; # default: 300
        };
        autoLock = true;
        #timeout = 5; # minutes
        lockOnResume = true;
        passwordRequired = true;
      };
    };

    kwin = {
      effects = {
        blur = {
          enable = true;
          noiseStrength = 8;
          strength = 5;
        };
        cube.enable = true;
        desktopSwitching.animation = "fade";
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

      "launch-ghostty" = {
        name = "Launch Ghostty";
        key = "Meta+Alt+G";
        command = "ghostty";
      };

      "launch-warp" = {
        name = "Launch warp terminal";
        key = "Meta+Alt+w";
        command = "warp-terminal";
      };

      "custom-volume-down" = {
        name = "Volume Down";
        key = "Meta+F1";
        command = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
      };

      "custom-volume-up" = {
        name = "Volume Up";
        key = "Meta+F2";
        # '-l 1.5' allows volume to go up to 150%
        command = "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+";
      };
      "custom-brightness-up" = {
        name = "Brightness Up";
        key = "Meta+F3";
        command = "${pkgs.brightnessctl}/bin/brightnessctl set +5%";
      };
      "custom-brightness-down" = {
        name = "Brightness Down";
        key = "Meta+F4";
        command = "${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
      };
    };
    */

    # powerdevil and panel settings are pending
    # panel to be decided whether to go kde way or waybar like way
  };
}
