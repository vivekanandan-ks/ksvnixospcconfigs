{inputs, ...}: {
  flake-file.inputs = {
    # a hyprland plugin refer: https://github.com/KZDKM/Hyprspace
      /*Hyprspace = {
      url = "github:KZDKM/Hyprspace";
      # Hyprspace uses latest Hyprland. We declare this to keep them in sync.
      #inputs.hyprland.follows = "hyprland";
    };*/
  };
  flake = {
    homeModules.nonDroid.hyprspace = {pkgs, ...}: {
      wayland.windowManager.hyprland = {
        plugins = [
          #pkgs-unstable.hyprlandPlugins.hyprspace
          #inputs.Hyprspace.packages.${pkgs.stdenv.hostPlatform.system}.Hyprspace
        ];
        settings = {
          bind = [
            #"CTRL SUPER, TAB, overview:toggle"
          ];
        };
      };
    };
  };
}
