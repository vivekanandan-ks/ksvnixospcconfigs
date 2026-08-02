{...}: {
  flake = {
    homeModules.nonDroid.zen-transparency = {
      wayland.windowManager.hyprland.settings = {
        windowrule = [
          "opacity 0.9 0.9, match:class ^(zen.*)$"
        ];
      };
    };
  };
}
