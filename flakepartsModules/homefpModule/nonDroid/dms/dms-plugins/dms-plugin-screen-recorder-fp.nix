{inputs, ...}: {
  flake-file.inputs = {
    dms-plugin-screen-recorder = {
      url = "github:hthienloc/dms-screen-recorder";
      flake = false;
    };
  };

  flake.homeModules.nonDroid.dms-plugin-screen-recorder = {
    pkgs,
    lib,
    ...
  }: {
    programs.dank-material-shell.plugins.screenRecorderLH = {
      src = inputs.dms-plugin-screen-recorder;
      enable = true;
      settings = {
        recordingMode = "portal";
      };
    };

    dmsExtraPackages = [
      pkgs.gpu-screen-recorder
      pkgs.slurp
      pkgs.ffmpeg
      pkgs.libnotify
    ];

    wayland.windowManager.mango.settings.bind = lib.mkAfter [
      "SUPER+SHIFT, R, spawn, dms ipc screenRecorderLH togglePortal"
      "SUPER+ALT, R, spawn, dms ipc screenRecorderLH togglePortal"
    ];
  };
}
