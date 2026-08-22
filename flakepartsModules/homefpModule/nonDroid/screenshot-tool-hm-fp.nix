_: {
  flake.homeModules.nonDroid.screenshot-tool = {
    config,
    lib,
    pkgs-unstable,
    ...
  }: {
    # Flameshot service configuration
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

    systemd.user.services.flameshot.Unit = {
      After = ["mango-session.target" "graphical-session.target"];
      PartOf = ["mango-session.target" "graphical-session.target"];
    };

    # Hyprland screenshot bindings
    wayland.windowManager.hyprland.settings.bind = lib.mkAfter [
      ", Print, exec, flameshot gui"
      "SUPER, Print, exec, flameshot full"
    ];

    # Xremap screenshot bindings
    services.xremap.config.keymap = lib.mkAfter [
      {
        name = "Screenshot shortcuts";
        remap = {
          "Ctrl-SYSRQ".launch = ["flameshot" "gui"];
          "Ctrl-Super-SYSRQ".launch = ["flameshot" "full"];
          "Ctrl-PRINT".launch = ["flameshot" "gui"];
          "Ctrl-Super-PRINT".launch = ["flameshot" "full"];
        };
      }
    ];
  };
}
