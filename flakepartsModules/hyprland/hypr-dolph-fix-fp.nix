_: {
  flake = {
    nixosModules.hypr-dolph-fix = {pkgs, ...}: {
      xdg.menus.enable = true;
      xdg.mime.enable = true;
      environment.etc."xdg/menus/applications.menu" = {
        source = "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";
      };
    };

    homeModules.nonDroid.hypr-dolph-fix = {
      lib,
      pkgs,
      ...
    }: {
      home.activation.rebuildKDECache = lib.hm.dag.entryAfter ["writeBoundary"] ''
        rm -rf ~/.cache/ksycoca*
        ${pkgs.kdePackages.kservice}/bin/kbuildsycoca6 --noincremental
      '';

      wayland.windowManager.hyprland.settings = {
        env = [
          "XDG_MENU_PREFIX,plasma-"
        ];
      };
    };
  };
}
