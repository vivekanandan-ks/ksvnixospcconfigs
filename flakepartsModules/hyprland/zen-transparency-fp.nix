{...}: {
  flake = {
    homeModules.nonDroid.zen-transparency = {
      wayland.windowManager.hyprland.settings = {
        windowrule = [
          "opacity 0.8 0.8, match:class:^(zen.*)$"
        ];
      };
    };
  };
}
