{...}: {
  flake = {
    homeModules.nonDroid.zen-transparency = {
      wayland.windowManager.hyprland.settings = {
        windowrulev2 = [
          "opacity 0.8 0.8, class:^(zen.*)$"
        ];
      };
    };
  };
}
