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

  flake.homeModules.nonDroid.dms-plugins = _: {
    programs.dank-material-shell.plugins = {
      # Standalone Plugins
      wallpaperCarousel.src = inputs.dms-plugin-wallpaper-carousel;
      hiddenBar.src = inputs.dms-plugin-hidden-bar;
      networkIndicator.src = inputs.dms-plugin-network-indicator;
      batteryPlus.src = inputs.dms-plugin-battery-plus;
      usbManager.src = inputs.dms-plugin-usb-manager;
      ModernClock.src = inputs.dms-plugin-modern-clock;

      # Dadangdut33 Collection
      MediaControlPlus.src = "${inputs.dms-plugins-dadangdut33}/MediaControlPlus";
      SimpleAudioControl.src = "${inputs.dms-plugins-dadangdut33}/SimpleAudioControl";
      ClipboardPlus.src = "${inputs.dms-plugins-dadangdut33}/ClipboardPlus";
      SystemMonitorPlus.src = "${inputs.dms-plugins-dadangdut33}/SystemMonitorPlus";

      # AvengeMedia Collection
      DankActions.src = "${inputs.dms-plugins-avengemedia}/DankActions";
      DankClight.src = "${inputs.dms-plugins-avengemedia}/DankClight";
      DankLauncherKeys.src = "${inputs.dms-plugins-avengemedia}/DankLauncherKeys";
      DankKDEConnect.src = "${inputs.dms-plugins-avengemedia}/DankKDEConnect";
      DankPomodoroTimer.src = "${inputs.dms-plugins-avengemedia}/DankPomodoroTimer";
      DankDesktopWeather.src = "${inputs.dms-plugins-avengemedia}/DankDesktopWeather";
      DankGifSearch.src = "${inputs.dms-plugins-avengemedia}/DankGifSearch";
      DankBatteryAlerts.src = "${inputs.dms-plugins-avengemedia}/DankBatteryAlerts";
      DankNotepadModule.src = "${inputs.dms-plugins-avengemedia}/DankNotepadModule";
      DankHyprlandWindows.src = "${inputs.dms-plugins-avengemedia}/DankHyprlandWindows";
      DankStickerSearch.src = "${inputs.dms-plugins-avengemedia}/DankStickerSearch";
      DankHooks.src = "${inputs.dms-plugins-avengemedia}/DankHooks";
    };
  };
}
