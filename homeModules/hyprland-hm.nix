{
  inputs,
  pkgs,
  pkgs-unstable,
  system,
  ...
}:
{
  # Fixing problems with themes
  # refer this: https://wiki.hypr.land/Nix/Hyprland-on-Home-Manager/#faq

  /*
    home.pointerCursor = {
      gtk.enable = true;
      # x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 16;
    };

    gtk = {
      enable = true;

      theme = {
        package = pkgs.flat-remix-gtk;
        name = "Flat-Remix-GTK-Grey-Darkest";
      };

      iconTheme = {
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
      };

      font = {
        name = "Sans";
        size = 11;
      };
    };
  */

  wayland.windowManager.hyprland =
    let
      hyprland-pkg = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      enable = true;
      # set the flake package
      #package = hyprland-pkg.hyprland;
      package = null;
      #portalPackage = hyprland-pkg.xdg-desktop-portal-hyprland;
      portalPackage = null;

      systemd.enable = true; # default true
      xwayland.enable = true; # default true
      plugins = with inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}; [
        hyprbars
        hyprexpo
        hyprtrails
        #inputs.hyprlock.packages.${pkgs.system}.hyprlock
        inputs.hypr-dynamic-cursors.packages.${pkgs.system}.hypr-dynamic-cursors # https://github.com/VirtCode/hypr-dynamic-cursors
        #hyprscrolling
        #inputs.Hyprspace.packages.${pkgs.system}.Hyprspace # not a good impression, buggy I guess also no demo video
        #inputs.hyprtasking.packages.${pkgs.system}.hyprtasking # unofficial hyprexpo alternative

      ];
      settings = {
        
        resize_on_border = true;




      };

    };

}
