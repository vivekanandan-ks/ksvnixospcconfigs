{
  self,
  lib,
  ...
}: {
  # ---------------------------------------------------------------------------
  # 1. Package definition using appimageTools.wrapType2
  # ---------------------------------------------------------------------------
  perSystem = {pkgs, ...}: let
    pname = "wifi-audio-streaming";
    version = "1.2.0";

    src = pkgs.fetchurl {
      url = "https://github.com/marcomorosi06/WiFiAudioStreaming-Desktop/releases/download/v1.2/WiFi-Audio-Streaming-${version}-linux-x86_64.AppImage";
      hash = "sha256-T1CkDdHWLjInuRxsKzE0TfQSphAEvl5R1z3UAVh6TcY=";
    };

    appimageContents = pkgs.appimageTools.extract {
      inherit pname version src;
    };
  in {
    packages.wifi-audio-streaming = pkgs.appimageTools.wrapType2 {
      inherit pname version src;

      extraPkgs = pkgs:
        with pkgs; [
          # Wayland & Keyboard dlopen
          wayland
          libxkbcommon

          # Graphics & Skiko hardware acceleration
          libGL
          libglvnd
          vulkan-loader
          libx11
          libxext
          libxi
          libxrender
          libxtst
          libxcursor
          libxrandr
          libxcomposite
          libxdamage
          libxfixes

          # Audio backend (PipeWire, PulseAudio, ALSA)
          alsa-lib
          libpulseaudio
          pipewire

          # Tray icon & Notifications
          libayatana-appindicator
          gtk3

          # Fonts & Typography
          fontconfig
          freetype
        ];

      extraInstallCommands = ''
        install -m 444 -D ${appimageContents}/wifi-audio-streaming.desktop $out/share/applications/wifi-audio-streaming.desktop
        install -m 444 -D ${appimageContents}/wifi-audio-streaming.png $out/share/icons/hicolor/512x512/apps/wifi-audio-streaming.png

        substituteInPlace $out/share/applications/wifi-audio-streaming.desktop \
          --replace-fail 'Exec=AppRun' "Exec=$out/bin/${pname}"

        # Expose wfas CLI symlink
        ln -s $out/bin/${pname} $out/bin/wfas
      '';

      meta = with lib; {
        description = "Turn your computer into a wireless audio transmitter or receiver (WFAS, RTP, HTTP, DLNA, Snapcast)";
        homepage = "https://github.com/marcomorosi06/WiFiAudioStreaming-Desktop";
        license = licenses.eupl12;
        platforms = ["x86_64-linux"];
        mainProgram = pname;
      };
    };

    # Convenience aliases
    packages.wfas = self.packages.${pkgs.stdenv.hostPlatform.system}.wifi-audio-streaming;
  };

  # ---------------------------------------------------------------------------
  # 2. Auto-installs into Home Manager across all non-Droid hosts
  # ---------------------------------------------------------------------------
  flake.homeModules.nonDroid.wifi-audio-streaming = {pkgs, ...}: {
    home.packages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.wifi-audio-streaming
    ];
  };
}
