{inputs, ...}: {
  flake-file.inputs.gloview = {
    url = "github:fedsfarm/gloview";
    flake = false;
  };

  flake.homeModules.nonDroid.gloview = {pkgs, ...}: {
    wayland.windowManager.hyprland = {
      plugins = [
        inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.gloview
      ];
      settings.bind = [
        "SUPER, G, gloview:toggle"
        "SUPER SHIFT, G, gloview:desktop"
        "SUPER CTRL, G, gloview:allworkspaces"
        "SUPER, bracketright, gloview:next"
        "SUPER, bracketleft, gloview:prev"
      ];
    };
  };

  perSystem = {pkgs, ...}: {
    packages.gloview = pkgs.hyprlandPlugins.mkHyprlandPlugin {
      pluginName = "gloview";
      version = "latest";

      src = inputs.gloview;

      nativeBuildInputs = [
        pkgs.pkg-config
        pkgs.cmake
      ];

      buildInputs = [ pkgs.luajit ];

      meta = with pkgs.lib; {
        description = "A better macOS Mission Control-style overview plugin for Hyprland";
        homepage = "https://github.com/fedsfarm/gloview";
        license = licenses.gpl3;
        platforms = platforms.linux;
      };

      buildPhase = ''
        cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
        cmake --build build -j$NIX_BUILD_CORES
      '';

      installPhase = ''
        mkdir -p $out/lib
        cp build/gloview.so $out/lib/
        ln -sf gloview.so $out/lib/libgloview.so
      '';
      
      dontUseCmakeConfigure = true;
    };
  };
}
