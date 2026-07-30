{inputs, ...}: {
  flake-file.inputs = {
    hyprexpo = {
      url = "github:colonelpanic8/hyprexpo";
      #inputs.hyprland.follows = "hyprland";
    };
  };
  flake = {
    homeModules.nonDroid.hyprexpo = {pkgs, ...}: {
      wayland.windowManager.hyprland = {
        plugins = [inputs.hyprexpo.packages.${pkgs.stdenv.hostPlatform.system}.hyprexpo];
        #settings.bind = ["SUPER, TAB, gloview:toggle"];
      };
    };
  };
}
