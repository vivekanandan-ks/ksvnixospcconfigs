{lib, ...}: {
  flake.nixosModules.xdg-portal = {pkgs-unstable, ...}: {
    # Enable XDG Desktop Portals for GTK File Pickers & Dialogs under Hyprland
    xdg.portal = {
      enable = true;
      extraPortals = lib.mkForce [
        pkgs-unstable.xdg-desktop-portal-gtk
        pkgs-unstable.xdg-desktop-portal-hyprland
      ];
      config.common.default = [
        "hyprland"
        "gtk"
      ];
    };
  };
}
