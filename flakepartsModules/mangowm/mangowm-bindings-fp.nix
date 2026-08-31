_: {
  flake = {
    homeModules.nonDroid.mangowc-bindings = {lib, ...}: {
      wayland.windowManager.mango.settings = {
        # Mouse bindings for moving & resizing windows
        mousebind = [
          "SUPER, btn_left, moveresize, curmove"
          "SUPER, btn_right, moveresize, curresize"
        ];

        bind =
          [
            # Layout switching (Direct: Alt + Shift + 1-9 & symbols)
            "ALT+SHIFT, 1, setlayout, scroller"
            "ALT+SHIFT, 2, setlayout, tile"
            "ALT+SHIFT, 3, setlayout, dwindle"
            "ALT+SHIFT, 4, setlayout, grid"
            "ALT+SHIFT, 5, setlayout, monocle"
            "ALT+SHIFT, 6, setlayout, deck"
            "ALT+SHIFT, 7, setlayout, center_tile"
            "ALT+SHIFT, 8, setlayout, right_tile"
            "ALT+SHIFT, 9, setlayout, vertical_scroller"
            "ALT+SHIFT, 0, setlayout, vertical_tile"
            "ALT+SHIFT, minus, setlayout, vertical_grid"
            "ALT+SHIFT, equal, setlayout, vertical_deck"
            "ALT+SHIFT, bracketleft, setlayout, fair"
            "ALT+SHIFT, bracketright, setlayout, vertical_fair"

            # Layout cycling (Super + \)
            "SUPER, backslash, switch_layout"

            # Close window
            "ALT, F4, killclient"

            # Shell / Spotlight launcher
            "SUPER, Space, spawn, dms ipc call spotlight toggle"

            # Wallpaper Carousel
            "SUPER, w, spawn, dms ipc wallpaperCarousel toggle"

            # Power menu (Ctrl + Alt + Del)
            "CTRL+ALT, Delete, spawn, dms ipc call powermenu toggle"

            # Window overview (Mission control with hold Super to cycle)
            "SUPER, Tab, overcircle, next"
            "SUPER+SHIFT, Tab, togglejump"

            # Window thumbnail HUD switcher (Alt + Tab)
            "ALT, Tab, switcher, next"
            "ALT+SHIFT, Tab, switcher, all_tag_next"
            "ALT, grave, focuslast"

            # Direct focus cycling (Super + , / Super + .)
            "SUPER, comma, focusstack, prev"
            "SUPER, period, focusstack, next"

            # Window states
            "SUPER, f, togglefullscreen"
            "SUPER, s, togglefloating"

            # Directional focus
            "SUPER, h, focusdir, left"
            "SUPER, l, focusdir, right"
            "SUPER, k, focusdir, up"
            "SUPER, j, focusdir, down"
          ]
          # Switch to workspace/tag 1-9 (Super + 1..9)
          ++ (map (i: "SUPER, ${toString i}, view, ${toString i}") (lib.range 1 9))
          # Move focused window to workspace/tag 1-9 (Super + Shift + 1..9)
          ++ (map (i: "SUPER+SHIFT, ${toString i}, tag, ${toString i}") (lib.range 1 9));
      };
    };
  };
}
