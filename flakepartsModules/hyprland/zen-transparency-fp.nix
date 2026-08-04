{...}: {
  flake = {
    homeModules.nonDroid.zen-transparency = {
      wayland.windowManager.hyprland.settings = {
        windowrule = [
          "opacity 0.97 0.97, match:class ^(zen.*)$"
        ];
      };
    };
  };
}
