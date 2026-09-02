{inputs, ...}: {
  flake-file.inputs = {
    # Standalone Plugins
    dms-plugin-wallpaper-carousel = {
      url = "github:motor-dev/wallpaperCarousel";
      flake = false;
    };
    dms-plugin-hidden-bar = {
      url = "github:hthienloc/dms-hidden-bar";
      flake = false;
    };
    dms-plugin-network-indicator = {
      url = "github:gemb0-0/Network-Indicator";
      flake = false;
    };
    dms-plugin-battery-plus = {
      url = "github:arcatva/dms-battery-plus";
      flake = false;
    };
    dms-plugin-usb-manager = {
      url = "github:NordicsSys/dms-usb-manager";
      flake = false;
    };
    dms-plugin-modern-clock = {
      url = "github:beefsizzle/ModernClockDMS";
      flake = false;
    };
    dms-plugin-pure-lyrics = {
      url = "github:lildengzi/pureLyrics";
      flake = false;
    };
    dms-plugin-material-player = {
      url = "github:notsopreety/materialPlayer";
      flake = false;
    };
    dms-plugin-battery-osd = {
      url = "github:notsopreety/batteryOSD";
      flake = false;
    };
    dms-plugin-caffeine = {
      url = "github:JDKamalakar/DMS-Caffeine";
      flake = false;
    };
    dms-plugin-cpu-core-load = {
      url = "github:rabits/dms-plugin-cpucoreload";
      flake = false;
    };
    dms-plugin-dns-switcher = {
      url = "github:JDKamalakar/DMS-DNS_Switcher";
      flake = false;
    };
    dms-plugin-take-a-break = {
      url = "github:hthienloc/dms-take-a-break";
      flake = false;
    };
    dms-plugin-music-theme = {
      url = "github:felipeadeildo/dms-music-theme";
      flake = false;
    };
    dms-plugin-ambient-sound = {
      url = "github:hthienloc/dms-ambient-sound";
      flake = false;
    };
    dms-plugin-storage-monitor = {
      url = "github:YoungJurry/dms-storage-monitor";
      flake = false;
    };
    dms-plugin-dank-cleaner = {
      url = "github:NordicsSys/dankCleaner";
      flake = false;
    };
    dms-plugin-tabs-launcher = {
      url = "github:kmf/dms-tabs-launcher";
      flake = false;
    };

    # Plugin Collections (Monorepos)
    dms-plugins-avengemedia = {
      url = "github:AvengeMedia/dms-plugins";
      flake = false;
    };
    dms-plugins-dadangdut33 = {
      url = "github:Dadangdut33/dms-plugins";
      flake = false;
    };
  };

  flake.homeModules.nonDroid.dms-plugins = {pkgs, ...}: {
    programs.dank-material-shell.plugins = {
      # Standalone Plugins
      wallpaperCarousel = {
        src = inputs.dms-plugin-wallpaper-carousel;
        settings = {
          overlayOpacity = 73;
        };
      };
      hiddenBar.src = inputs.dms-plugin-hidden-bar;
      networkIndicator.src = inputs.dms-plugin-network-indicator;
      batteryPlus.src = inputs.dms-plugin-battery-plus;
      usbManager.src = inputs.dms-plugin-usb-manager;
      modernClock.src = inputs.dms-plugin-modern-clock;
      pureLyrics.src = inputs.dms-plugin-pure-lyrics;
      materialPlayer.src = inputs.dms-plugin-material-player;
      batteryOSD.src = inputs.dms-plugin-battery-osd;

      # User Plugins
      caffeineRedesigned.src = inputs.dms-plugin-caffeine;
      cpuCoreLoad.src = inputs.dms-plugin-cpu-core-load;
      dnsSwitcher.src = inputs.dms-plugin-dns-switcher;
      takeABreak.src = inputs.dms-plugin-take-a-break;
      musicTheme.src = inputs.dms-plugin-music-theme;
      ambientSound.src = inputs.dms-plugin-ambient-sound;
      storageMonitor.src = inputs.dms-plugin-storage-monitor;
      dankCleaner.src = inputs.dms-plugin-dank-cleaner;
      tabsLauncher.src = inputs.dms-plugin-tabs-launcher;

      # Dadangdut33 Collection
      mediaControlPlus.src = "${inputs.dms-plugins-dadangdut33}/MediaControlPlus";
      simpleAudioControl.src = "${inputs.dms-plugins-dadangdut33}/SimpleAudioControl";
      clipboardPlus = {
        src = "${inputs.dms-plugins-dadangdut33}/ClipboardPlus";
        enable = true;
      };
      systemMonitorPlus = {
        src = "${inputs.dms-plugins-dadangdut33}/SystemMonitorPlus";
        enable = false;
      };

      # AvengeMedia Collection
      dankActions = {
        src = "${inputs.dms-plugins-avengemedia}/DankActions";
        enable = false;
      };
      dankBatteryAlerts = {
        src = "${inputs.dms-plugins-avengemedia}/DankBatteryAlerts";
        enable = true;
        settings = {
          warningThreshold = 50;
          criticalThreshold = 30;
        };
      };
      dankClight.src = "${inputs.dms-plugins-avengemedia}/DankClight";
      dankLauncherKeys.src = "${inputs.dms-plugins-avengemedia}/DankLauncherKeys";
      dankKDEConnect.src = "${inputs.dms-plugins-avengemedia}/DankKDEConnect";
      dankPomodoroTimer.src = "${inputs.dms-plugins-avengemedia}/DankPomodoroTimer";
      dankDesktopWeather.src = "${inputs.dms-plugins-avengemedia}/DankDesktopWeather";
      dankGifSearch.src = "${inputs.dms-plugins-avengemedia}/DankGifSearch";
      dankNotepadModule.src = "${inputs.dms-plugins-avengemedia}/DankNotepadModule";
      dankStickerSearch.src = "${inputs.dms-plugins-avengemedia}/DankStickerSearch";
      dankHooks.src = "${inputs.dms-plugins-avengemedia}/DankHooks";
    };

    dmsExtraPackages = [
      pkgs.socat
      pkgs.udisks2
    ];
  };
}
