{...}: {
  flake = {
    homeModules.nonDroid.hyprspace = {
      pkgs-unstable,
      ...
    }: {
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
