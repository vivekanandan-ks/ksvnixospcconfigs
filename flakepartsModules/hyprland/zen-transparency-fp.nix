{...}: {
  flake = {
    homeModules.nonDroid.zen-transparency = {
      wayland.windowManager.hyprland.settings = {
        windowrule = [
          "opacity 0.99 0.99, match:class ^(zen.*)$"
        ];
      };
    };
  };
}
