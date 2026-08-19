{
  inputs,
  self,
  ...
}: {
  flake-file.inputs = {
    #noctalia = {
    #  url = "github:noctalia-dev/noctalia-shell";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    noctalia-legacy-v4-plugins = {
      url = "github:noctalia-dev/legacy-v4-plugins";
      flake = false;
    };
  };

  perSystem = {
    pkgs,
    pkgs-mv-fast-tip,
    ...
  }: {
    packages.ksvNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
      runtimePkgs = with pkgs-mv-fast-tip; [
        grim
        slurp
        wl-clipboard
        satty
        libnotify
        imagemagick
        tesseract
        #wf-recorder
        jq
        xdg-utils
      ];
      # outOfStoreConfig = "/home/ksvnixospc/.config/noctalia-shell";
      settings =
        pkgs.lib.recursiveUpdate
        (
          builtins.fromJSON (
            builtins.readFile ./ksv-noctalia.json
          )
        )
        {
          general.avatarImage = "${self.personas.ksv.avatar}";
          wallpaper.directory = "${self.personas.ksv.wallpaperSet}";
          wallpaper.useWallhaven = false;
          wallpaper.useOriginalImages = true;
          wallpaper.automationEnabled = true;
          wallpaper.randomIntervalSec = 300;
          wallpaper.showHiddenFiles = true;
        };

      preInstalledPlugins = {
        clipper = {
          enabled = true;
          src = "${inputs.noctalia-legacy-v4-plugins.outPath}/clipper";
        };
        catwalk = {
          enabled = true;
          src = pkgs.symlinkJoin {
            name = "catwalk-with-settings";
            paths = [
              "${inputs.noctalia-legacy-v4-plugins.outPath}/catwalk"
              (pkgs.writeTextDir "settings.json" ''
                {
                  "minimumThreshold": 50,
                  "hideBackground": true
                }
              '')
            ];
          };
        };
        hot-corners = {
          enabled = true;
          src = pkgs.symlinkJoin {
            name = "hot-corners-with-settings";
            paths = [
              "${inputs.noctalia-legacy-v4-plugins.outPath}/hot-corners"
              # Previous implementation: "BottomLeft": "hyprctl -i 0 dispatch gloview:allworkspaces",
              (pkgs.writeTextDir "settings.json" ''
                {
                  "corners": {
                    "TopLeft": "hyprctl -i 0 dispatch gloview:toggle",
                    "BottomLeft": "hyprctl -i 0 dispatch scrolloverview:overview toggle",
                    "BottomRight": "hyprctl -i 0 dispatch workspace empty"
                  }
                }
              '')
            ];
          };
        };
        netbird = {
          enabled = true;
          src = pkgs.symlinkJoin {
            name = "netbird-with-settings";
            paths = [
              "${inputs.noctalia-legacy-v4-plugins.outPath}/netbird"
              (pkgs.writeTextDir "settings.json" ''
                {
                  "refreshInterval": 30000,
                  "compactMode": true,
                  "showPing": true
                }
              '')
            ];
          };
        };
        network-indicator = {
          enabled = true;
          src = pkgs.symlinkJoin {
            name = "network-indicator-with-settings";
            paths = [
              "${inputs.noctalia-legacy-v4-plugins.outPath}/network-indicator"
              (pkgs.writeTextDir "settings.json" ''
                {
                  "fontSizeModifier": 1.25,
                  "useCustomColors": true,
                  "colorText": "#ffffff"
                }
              '')
            ];
          };
        };
        plugin-manager = {
          enabled = true;
          src = "${inputs.noctalia-legacy-v4-plugins.outPath}/plugin-manager";
        };
        privacy-indicator = {
          enabled = false;
          src = "${inputs.noctalia-legacy-v4-plugins.outPath}/privacy-indicator";
        };
        screen-shot-and-record = {
          enabled = true;
          # src = "${inputs.noctalia-legacy-v4-plugins.outPath}/screen-shot-and-record";
          src = pkgs.symlinkJoin {
            name = "screen-shot-and-record-with-settings";
            paths = [
              "${inputs.noctalia-legacy-v4-plugins.outPath}/screen-shot-and-record"
              (pkgs.writeTextDir "settings.json" ''
                {
                  "screenshotEditor": "satty",
                  "savePath": "~/Pictures/Screenshots",
                  "keepSourceScreenshot": false,
                  "enableCross": true,
                  "enableWindowsSelection": true
                }
              '')
            ];
          };
        };
        usb-drive-manager = {
          enabled = true;
          src = "${inputs.noctalia-legacy-v4-plugins.outPath}/usb-drive-manager";
        };
        workspace-overview = {
          enabled = true;
          src = "${inputs.noctalia-legacy-v4-plugins.outPath}/workspace-overview";
        };
        mpvpaper = {
          enabled = false;
          src = "${inputs.noctalia-legacy-v4-plugins.outPath}/mpvpaper";
        };
        video-wallpaper = {
          enabled = false;
          src = "${inputs.noctalia-legacy-v4-plugins.outPath}/video-wallpaper";
        };
      };
    };
  };

  flake = {
    homeModules.nonDroid.noctalia = {
      config,
      pkgs,
      pkgs-unstable,
      lib,
      ...
    }: {
      # Noctalia screenshot & recording plugin dependencies (commented out to rely solely on Noctalia's runtimePkgs wrapper)
      # home.packages = with pkgs-unstable; [
      #   grim
      #   slurp
      #   satty
      #   wl-clipboard
      #   imagemagick
      #   tesseract
      #   #wf-recorder
      #   jq
      # ];

      # Configure Satty settings & output directory for Noctalia plugin
      programs.satty = {
        enable = true;
        package = pkgs-unstable.satty;
        settings = {
          general = {
            output-filename = "${config.xdg.userDirs.pictures}/sattyScreenshots/satty-%Y-%m-%d_%H:%M:%S.png";
            save-after-copy = true;
          };
        };
      };

      # declarative plugin settings management, for now just add the changes to the .config/noctalia/plugins directory and sync them to here, as like a backup
      #xdg.configFile."noctalia-shell/plugins".source = ./noctalia-plugins;

      systemd.user.services.noctalia = {
        Unit = {
          Description = "Noctalia Shell";
        };
        Service = {
          ExecStart = "${lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.ksvNoctalia}";
          Restart = "on-failure";
        };
      };
    };
  };

  /*
  Hot Corners Plugin Configuration Notes:
  - Top Left Command: `hyprctl dispatch gloview:toggle`
  - Bottom Right: `hyprctl -i 0 dispatch workspace empty`
  */
}
