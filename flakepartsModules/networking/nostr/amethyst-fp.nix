{
  self,
  lib,
  ...
}: {
  # ---------------------------------------------------------------------------
  # 1. Package definition using appimageTools.wrapType2
  # ---------------------------------------------------------------------------
  perSystem = {pkgs, ...}: let
    pname = "amethyst-desktop";
    version = "1.19.0";

    src = pkgs.fetchurl {
      url = "https://github.com/vitorpamplona/amethyst/releases/download/v${version}/amethyst-desktop-${version}-x86_64.AppImage";
      hash = "sha256-wwc9S1lcgZ2JL8ksDR5t9kcSPmp1CygtKw/duBlEy7w=";
    };

    appimageContents = pkgs.appimageTools.extract {
      inherit pname version src;
    };
  in {
    packages.amethyst-desktop = pkgs.appimageTools.wrapType2 {
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

          # Audio backend
          alsa-lib
          libpulseaudio
          pipewire

          # Fonts & Typography
          fontconfig
          freetype

          # Media playback (ComposeMediaPlayer)
          gst_all_1.gstreamer
          gst_all_1.gst-plugins-base
          gst_all_1.gst-plugins-good
          gst_all_1.gst-plugins-bad
          gst_all_1.gst-libav
          ffmpeg
        ];

      extraInstallCommands = ''
        install -m 444 -D ${appimageContents}/amethyst.desktop $out/share/applications/amethyst.desktop
        install -m 444 -D ${appimageContents}/amethyst.png $out/share/icons/hicolor/512x512/apps/amethyst.png

        substituteInPlace $out/share/applications/amethyst.desktop \
          --replace-fail 'Exec=Amethyst' "Exec=$out/bin/${pname}"
      '';

      meta = with lib; {
        description = "Amethyst Nostr client for Desktop (Compose Multiplatform)";
        homepage = "https://github.com/vitorpamplona/amethyst";
        license = licenses.mit;
        platforms = ["x86_64-linux"];
        mainProgram = pname;
      };
    };

    # Convenience alias for `nix run .#amethyst`
    packages.amethyst = self.packages.${pkgs.stdenv.hostPlatform.system}.amethyst-desktop;
  };

  # ---------------------------------------------------------------------------
  # 2. Auto-installs into Home Manager across all non-Droid hosts
  # ---------------------------------------------------------------------------
  flake.homeModules.nonDroid.amethyst = {pkgs, ...}: {
    home.packages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.amethyst-desktop
    ];
  };
}
