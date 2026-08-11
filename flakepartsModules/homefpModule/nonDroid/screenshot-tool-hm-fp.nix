_: {
  flake.homeModules.nonDroid.screenshot-tool = {
    config,
    pkgs-unstable,
    ...
  }: {
    services.flameshot = {
      enable = true;
      package = pkgs-unstable.flameshot;
      settings = {
        General = {
          disabledTrayIcon = false;
          showHelp = false;
          savePath = "${config.xdg.userDirs.pictures}/Screenshots";
          savePathFixed = true;
        };
      };
    };
  };

  flake.homeModules.nonDroid.xremap = {
    lib,
    ...
  }: {
    services.xremap.config.keymap = lib.mkAfter [
      {
        name = "Screenshot shortcuts";
        remap = {
          "Ctrl-PRINT".launch = ["flameshot" "gui"];
          "Ctrl-Super-PRINT".launch = ["flameshot" "full"];
        };
      }
    ];
  };
}
