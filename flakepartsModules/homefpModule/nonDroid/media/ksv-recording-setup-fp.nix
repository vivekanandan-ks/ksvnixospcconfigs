{
  inputs,
  lib,
  ...
}: {
  flake-file.inputs = {
    ksv-recording-setup.url = "github:vivekanandan-ks/ksv-recording-setup";
  };

  flake.homeModules.nonDroid.ksv-recording-setup = {pkgs, ...}: let
    micPkg = inputs.ksv-recording-setup.packages.${pkgs.stdenv.hostPlatform.system}.default;
  in {
    # Install directly to PATH for CLI usage (`android-mic`)
    home.packages = [
      micPkg
    ];

    # Desktop launcher (searchable via DMS Spotlight: SUPER + Space)
    xdg.desktopEntries.android-mic = {
      name = "AndroidMic";
      genericName = "Virtual Microphone";
      comment = "Use Android device as PC microphone over USB ADB";
      exec = "android-mic";
      icon = "audio-input-microphone";
      terminal = false;
      categories = [
        "AudioVideo"
        "Audio"
        "Recorder"
      ];
    };

    # MangoWM Keybinding: Super + Shift + a
    wayland.windowManager.mango.settings.bind = lib.mkAfter [
      "SUPER+SHIFT, a, spawn, android-mic"
    ];
  };
}
