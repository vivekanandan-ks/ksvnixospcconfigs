{inputs, ...}: {
  flake-file.inputs.scrolloverview = {
    url = "github:yayuuu/hyprland-scroll-overview";
    flake = false;
  };

  flake.homeModules.nonDroid.scrolloverview = {pkgs, ...}: {
    wayland.windowManager.hyprland = {
      plugins = [
        inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.scrolloverview
      ];
      settings.bind = [
        "SUPER, s, scrolloverview:overview, toggle"
      ];
    };
  };

  perSystem = {pkgs, ...}: {
    packages.scrolloverview = pkgs.hyprlandPlugins.mkHyprlandPlugin {
      pluginName = "scrolloverview";
      version = "latest";

      src = inputs.scrolloverview;

      nativeBuildInputs = [
        pkgs.pkg-config
        pkgs.cmake
      ];

      buildInputs = [pkgs.lua5_4];

      meta = with pkgs.lib; {
        description = "An overview plugin like niri for Hyprland";
        homepage = "https://github.com/yayuuu/hyprland-scroll-overview";
        license = licenses.gpl3;
        platforms = platforms.linux;
      };

      buildPhase = ''
        cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
        cmake --build build -j$NIX_BUILD_CORES
      '';

      installPhase = ''
        mkdir -p $out/lib
        cp build/libscrolloverview.so $out/lib/scrolloverview.so
        ln -sf scrolloverview.so $out/lib/libscrolloverview.so
      '';

      dontUseCmakeConfigure = true;
    };
  };
}
