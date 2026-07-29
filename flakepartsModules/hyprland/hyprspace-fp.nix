{...}: {
  flake-file.inputs = {
    # a hyprland plugin refer: https://github.com/KZDKM/Hyprspace
    /*
      Hyprspace = {
      url = "github:KZDKM/Hyprspace";
      # Hyprspace uses latest Hyprland. We declare this to keep them in sync.
      inputs.hyprland.follows = "hyprland";
    };
    */
  };
  flake = {
    homeModules.nonDroid.hyprspace = {pkgs-unstable, ...}: {
      wayland.windowManager.hyprland = {
        plugins = [
          pkgs-unstable.hyprlandPlugins.hyprspace
        ];
        settings = {
          bind = [
            "CTRL SUPER, TAB, overview:toggle"
          ];
        };
      };
    };
  };
}
