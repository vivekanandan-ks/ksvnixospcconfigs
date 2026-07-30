{inputs, ...}: {
  flake-file.inputs = {
    /*gloview = {
      url = "github:fedsfarm/gloview";
      #inputs.hyprland.follows = "hyprland";
    };*/
  };
  flake = {
    homeModules.nonDroid.hyprspace = {pkgs, ...}: {
      wayland.windowManager.hyprland = {
        #plugins = [inputs.gloview.packages.${pkgs.stdenv.hostPlatform.system}.gloview];
        #settings.bind = ["SUPER, TAB, gloview:toggle"];
      };
    };
  };
}
