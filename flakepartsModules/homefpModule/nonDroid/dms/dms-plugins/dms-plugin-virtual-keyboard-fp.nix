{
  inputs,
  self,
  ...
}: {
  flake-file.inputs = {
    dms-plugins-sitolam = {
      url = "github:sitolam/dms-plugins";
      flake = false;
    };
  };

  flake.nixosModules.dms-plugin-virtual-keyboard = _: {
    programs.ydotool.enable = true;
    users.users.${self.personas.ksv.username}.extraGroups = ["ydotool"];
  };

  flake.homeModules.nonDroid.dms-plugin-virtual-keyboard = {lib, ...}: {
    programs.dank-material-shell.plugins.virtualKeyboard = {
      src = "${inputs.dms-plugins-sitolam}/plugins/virtualkeyboard";
      enable = true;
    };

    wayland.windowManager.mango.settings.bind = lib.mkAfter [
      "SUPER+SHIFT, K, spawn, dms ipc call virtualKeyboard toggle"
    ];
  };
}
