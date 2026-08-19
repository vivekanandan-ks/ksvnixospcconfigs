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
      };

      home.activation.rebuildKDECache = lib.hm.dag.entryAfter ["writeBoundary"] ''
        rm -rf ~/.cache/ksycoca*
        ${pkgs-unstable.kdePackages.kservice}/bin/kbuildsycoca6 --noincremental
      '';
    };
  };
}
