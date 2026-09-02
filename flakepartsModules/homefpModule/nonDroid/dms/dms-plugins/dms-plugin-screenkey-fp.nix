{inputs, ...}: {
  flake-file.inputs = {
    dms-plugin-screenkey = {
      url = "github:hthienloc/dms-screenkey";
      flake = false;
    };
  };

  flake.homeModules.nonDroid.dms-plugin-screenkey = {
    pkgs,
    lib,
    ...
  }: {
    programs.dank-material-shell = {
      # 1. Screenkey plugin directly from source
      # plugins.screenkey.src = inputs.dms-plugin-screenkey;
      plugins.screenkey = {
        src = inputs.dms-plugin-screenkey;
        settings = {
          enabled = true;
          animationType = "slide";
          overlayOpacity = 75;
          showMouseClicks = true;
          showModifierStatus = true;
          showShortcuts = true;
          showNormalKeys = false;
          showOnlyModifiers = false;
          ignoreFilterKeys = true;
          position = "bottom_center";
          roundedKeycaps = true;
          historyLimit = 2;
          macSymbols = false;
        };
      };

      # 2. Wrap dms binary to prefix PATH with dependencies (just like mango)
      package = pkgs.symlinkJoin {
        name = "dms-shell-wrapped";
        paths = [inputs.dms-shell.packages.${pkgs.stdenv.hostPlatform.system}.default];
        nativeBuildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/dms \
            --prefix PATH : ${lib.makeBinPath [
              pkgs.libinput
              pkgs.evtest
              pkgs.python3
            ]}
        '';
        meta.mainProgram = "dms";
      };
    };

    # MangoWM keybinding to toggle Screenkey overlay
    wayland.windowManager.mango.settings.bind = lib.mkAfter [
      "SUPER+ALT, k, spawn, dms ipc call screenkey toggle"
    ];

    # Disable visualizer on session startup after 5 seconds so it starts OFF
    wayland.windowManager.mango.autostart_sh = lib.mkAfter ''
      (sleep 5 && dms ipc call screenkey disable) &
    '';
  };
}
