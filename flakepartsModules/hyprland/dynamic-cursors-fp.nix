{...}: {
  flake = {
    homeModules.nonDroid.hyprland-dynamic-cursors = {
      pkgs-unstable,
      ...
    }: {
      wayland.windowManager.hyprland = {
        plugins = [
          pkgs-unstable.hyprlandPlugins.hypr-dynamic-cursors
        ];
        settings = {
          "plugin:dynamic-cursors" = {
            enabled = true;
            mode = "stretch";
            stretch = {
              limit = 3000;
            };
          };
        };
      };
    };
  };
}
