{inputs, ...}: {
  flake-file.inputs = {
    dms-plugins-sitolam = {
      url = "github:sitolam/dms-plugins";
      flake = false;
    };
  };

  flake.homeModules.nonDroid.dms-plugin-virtual-keyboard = {
    pkgs,
    lib,
    ...
  }: {
    programs.dank-material-shell.plugins.virtualKeyboard = {
      src = "${inputs.dms-plugins-sitolam}/plugins/virtualkeyboard";
      enable = true;
    };

    dmsExtraPackages = [
      pkgs.ydotool
    ];

    wayland.windowManager.mango.settings.bind = lib.mkAfter [
      "SUPER+SHIFT, K, spawn, dms ipc call virtualKeyboard toggle"
    ];
  };
}
