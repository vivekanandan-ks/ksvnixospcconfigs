_: {
  flake.homeModules.nonDroid.screenshot-tool = {
    config,
    lib,
    pkgs-unstable,
    ...
  }: let
    saveDir = "${config.xdg.userDirs.pictures}/Screenshots";
  in {
    # Flameshot service configuration
    services.flameshot = {
      enable = true;
      package = pkgs-unstable.flameshot;
      settings = {
        General = {
          disabledTrayIcon = false;
          showHelp = false;
          savePath = saveDir;
          savePathFixed = true;
        };
      };
    };

    systemd.user.services.flameshot.Unit = {
      After = ["mango-session.target" "graphical-session.target"];
      PartOf = ["mango-session.target" "graphical-session.target"];
    };

    # MangoWM screenshot bindings
    wayland.windowManager.mango.settings.bind = lib.mkAfter [
      "NONE, Print, spawn, flameshot gui"
      "SUPER, Print, spawn, flameshot full -c -p ${saveDir}"
    ];
  };
}
