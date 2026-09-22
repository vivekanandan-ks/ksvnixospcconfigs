{inputs, ...}: {
  flake-file.inputs = {
    dms-plugins-hthienloc = {
      url = "github:hthienloc/dms-plugins";
      flake = false;
    };
  };

  flake.homeModules.nonDroid.dms-plugin-screen-recorder = {
    pkgs,
    lib,
    ...
  }: {
    programs.dank-material-shell.plugins.quickCapture = {
      src = "${inputs.dms-plugins-hthienloc}/quickCapture";
      enable = true;
      settings = {
        recordingBackend = "auto";
        recordingCodec = "auto";
        recordingFormat = "mkv";
        recordingFramerate = "60";
        recordSystemAudio = true;
        recordCursor = true;
      };
    };

    dmsExtraPackages = [
      pkgs.gpu-screen-recorder
      pkgs.wf-recorder
      pkgs.slurp
      pkgs.ffmpeg
      pkgs.imagemagick
      pkgs.wl-clipboard
      pkgs.libnotify
      pkgs.tesseract
      pkgs.zbar
    ];

    wayland.windowManager.mango.settings.bind = lib.mkAfter [
      # Video Recording (Window / Portal)
      "SUPER+SHIFT, R, spawn, dms ipc call quickCapture recordToggle portal"
      "SUPER+ALT, R, spawn, dms ipc call quickCapture recordToggle portal"

      # Video Recording (Interactive Region)
      "SUPER+ALT, S, spawn, dms ipc call quickCapture recordToggle region"

      # Screenshot & Annotation (Region Edit)
      "SUPER+SHIFT, S, spawn, dms ipc call quickCapture screenshot region edit"
    ];
  };
}
