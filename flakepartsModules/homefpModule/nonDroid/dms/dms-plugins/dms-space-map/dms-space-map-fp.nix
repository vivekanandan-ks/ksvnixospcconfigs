_: {
  flake.homeModules.nonDroid.dms-plugin-space-map = {lib, ...}: {
    programs.dank-material-shell.plugins.spaceMap = {
      src = ./.;
      enable = true;
    };

    # Keybinding in MangoWM: Super + Alt + Tab to toggle Space Map
    wayland.windowManager.mango.settings.bind = lib.mkAfter [
      "SUPER+ALT, Tab, spawn, dms ipc call spaceMap toggle"
    ];
  };
}
