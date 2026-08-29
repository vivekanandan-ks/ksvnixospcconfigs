_: {
  /*
    flake-file.inputs.hyprglass = {
    url = "github:hyprnux/hyprglass";
    flake = false;
  };

  flake.homeModules.nonDroid.hyprglass = {pkgs, ...}: {
    wayland.windowManager.hyprland = {
      plugins = [
        inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.hyprglass
      ];
    };
  };
  perSystem = {pkgs, ...}: {
    packages.hyprglass = pkgs.hyprlandPlugins.mkHyprlandPlugin {
      pluginName = "hyprglass";
      version = "latest";

      src = inputs.hyprglass;

      nativeBuildInputs = [pkgs.pkg-config];

      # mkHyprlandPlugin automatically handles hyprland's own inputs,
      # we just need to add the extra ones required by hyprglass
      buildInputs = [pkgs.pixman pkgs.libdrm];

      meta = with pkgs.lib; {
        description = "Liquid Glass inspired plugin for Hyprland";
        homepage = "https://github.com/hyprnux/hyprglass";
        license = licenses.bsd3;
        platforms = platforms.linux;
      };

      buildPhase = ''
        make all
      '';

      installPhase = ''
        mkdir -p $out/lib
        cp hyprglass.so $out/lib/
        # Home Manager's hyprland module requires plugins to be prefixed with `lib`
        ln -sf hyprglass.so $out/lib/libhyprglass.so
      '';
    };
    };
  */
}
