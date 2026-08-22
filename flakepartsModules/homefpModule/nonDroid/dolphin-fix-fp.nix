_: {
  flake = {
    nixosModules.dolphin-fix = {pkgs-unstable, ...}: {
      xdg.menus.enable = true;
      xdg.mime.enable = true;
      environment.etc."xdg/menus/applications.menu" = {
        source = "${pkgs-unstable.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";
      };
    };

    homeModules.nonDroid.dolphin-fix = {
      lib,
      pkgs-unstable,
      ...
    }: {
      home.sessionVariables = {
        XDG_MENU_PREFIX = "plasma-";
        QT_QPA_PLATFORM = "wayland;xcb";
        QT_QPA_PLATFORMTHEME = "kde";
        QT_STYLE_OVERRIDE = "breeze";
      };

      home.activation.rebuildKDECache = lib.hm.dag.entryAfter ["writeBoundary"] ''
        rm -rf ~/.cache/ksycoca*
        ${pkgs-unstable.kdePackages.kservice}/bin/kbuildsycoca6 --noincremental
        ${pkgs-unstable.kdePackages.kconfig}/bin/kwriteconfig6 --file ~/.config/kdeglobals --group General --key TerminalApplication kitty
        ${pkgs-unstable.kdePackages.kconfig}/bin/kwriteconfig6 --file ~/.config/kdeglobals --group General --key TerminalService kitty.desktop
      '';

      xdg.configFile."xdg-terminals.list".text = "kitty.desktop\n";

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "x-scheme-handler/terminal" = ["kitty.desktop"];
          "terminal-emulator.desktop" = ["kitty.desktop"];
        };
      };
    };
  };
}
