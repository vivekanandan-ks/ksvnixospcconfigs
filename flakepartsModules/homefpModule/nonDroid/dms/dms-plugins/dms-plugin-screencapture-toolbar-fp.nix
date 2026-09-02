{inputs, ...}: {
  flake-file.inputs = {
    dms-plugin-screencapture-toolbar = {
      url = "github:JDKamalakar/DMS-ScreenCapture_Toolbar";
      flake = false;
    };
  };

  flake.homeModules.nonDroid.dms-plugin-screencapture-toolbar = {
    pkgs,
    lib,
    ...
  }: {
    programs.dank-material-shell.plugins.screenCaptureToolbar = {
      src = inputs.dms-plugin-screencapture-toolbar;
      enable = true;
      settings = {
        showAdvancedSettings = true;
        audioCodec = "opus";
      };
    };

    dmsExtraPackages = [
      pkgs.gpu-screen-recorder
      pkgs.slurp
      pkgs.grim
      pkgs.pulseaudio
      pkgs.jq
    ];

    wayland.windowManager.mango.settings.bind = lib.mkAfter [
      "SUPER+ALT, c, spawn, dms ipc call screenCaptureToolbar toggle"
    ];
  };
}
