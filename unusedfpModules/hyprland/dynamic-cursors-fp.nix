_: {
  flake = {
    homeModules.nonDroid.hyprland-dynamic-cursors = {pkgs-unstable, ...}: {
      wayland.windowManager.hyprland = {
        plugins = [
          pkgs-unstable.hyprlandPlugins.hypr-dynamic-cursors
        ];
        settings = {
          "plugin:dynamic-cursors" = {
            enabled = true;
            mode = "stretch";
            stretch = {
              limit = 1000;
              function = "negative_quadratic"; # Makes the stretch scale faster as you move faster
            };
          };
        };
      };
    };
  };
}
