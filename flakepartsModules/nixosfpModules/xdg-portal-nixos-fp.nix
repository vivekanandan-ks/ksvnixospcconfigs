_: {
  flake.nixosModules.xdg-portal = {pkgs-unstable, ...}: {
    # System-wide XDG Desktop Portals for file pickers, dialogs, and screen sharing
    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs-unstable.xdg-desktop-portal-gtk
        pkgs-unstable.xdg-desktop-portal-hyprland
        pkgs-unstable.xdg-desktop-portal-wlr
      ];
      config = {
        common.default = ["gtk"];
        hyprland.default = ["hyprland" "gtk"];
        niri.default = ["gnome" "gtk"];
        sway.default = ["wlr" "gtk"];
      };
    };
  };
}
