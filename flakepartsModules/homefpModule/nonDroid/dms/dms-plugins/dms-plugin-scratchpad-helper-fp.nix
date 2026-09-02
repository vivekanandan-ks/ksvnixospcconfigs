{inputs, ...}: {
  flake-file.inputs = {
    dms-plugin-scratchpad-helper = {
      url = "github:fluxwrk/dms-scratchpad-helper";
      flake = false;
    };
  };

  flake.homeModules.nonDroid.dms-plugin-scratchpad-helper = {
    pkgs,
    lib,
    ...
  }: {
    programs.dank-material-shell.plugins.scratchpadHelper = {
      src = inputs.dms-plugin-scratchpad-helper;
      enable = true;
    };

    dmsExtraPackages = [
      pkgs.grim
    ];

    # MangoWM keybinding to toggle Scratchpad Picker
    wayland.windowManager.mango.settings.bind = lib.mkAfter [
      "SUPER, grave, spawn, dms ipc call scratchpadHelper togglePicker"
    ];
  };
}
