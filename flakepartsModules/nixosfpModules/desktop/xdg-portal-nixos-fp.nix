_: {
  flake.nixosModules.xdg-portal = {
    lib,
    pkgs-unstable,
    ...
  }: {
    # System-wide XDG Desktop Portals for file pickers, dialogs, and screen sharing
    xdg.portal = {
      enable = true;
      wlr = {
        enable = true;
        settings = {
          screencast = {
            chooser_type = "dmenu";
            chooser_cmd = "${pkgs-unstable.wofi}/bin/wofi --dmenu --prompt 'Select Screen to Share'";
          };
        };
      };
      extraPortals = [
        pkgs-unstable.xdg-desktop-portal-gtk
      ];
      config = {
        common.default = ["gtk"];
        mango.default = lib.mkForce ["wlr" "gtk"];
        niri.default = ["gnome" "gtk"];
        sway.default = ["wlr" "gtk"];
      };
    };
  };
}
