{...}: {
  flake = {
    homeModules.nonDroid.hyprland-scrolling-layout = {...}: {
      wayland.windowManager.hyprland = {
        settings = {
          general = {
            layout = "scrolling";
          };

          scrolling = {
            column_width = 0.5;
            focus_fit_method = 1;
            direction = "right";
            # New 0.56 options
            wrap_focus = true;
            wrap_swapcol = true;
          };

          bind = [
            "$mainMod, period, layoutmsg, move +col"
            "$mainMod, comma, layoutmsg, move -col"
            "$mainMod SHIFT, period, layoutmsg, swapcol r"
            "$mainMod SHIFT, comma, layoutmsg, swapcol l"
            "$mainMod, F, layoutmsg, togglefit"
          ];
        };
      };
    };
  };
}
