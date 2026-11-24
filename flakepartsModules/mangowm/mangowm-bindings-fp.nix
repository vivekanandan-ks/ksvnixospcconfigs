_: {
  flake = {
    homeModules.nonDroid.mangowc-bindings = {lib, ...}: {
      wayland.windowManager.mango.settings = {
        # Mouse bindings for moving & resizing windows
        mousebind = [
          "SUPER, btn_left, moveresize, curmove"
          "SUPER, btn_right, moveresize, curresize"
        ];

        # Bindings that trigger even when the screen/session is locked
        bindl = [
          # Screen Wakeup / DPMS failsafe
          "SUPER+SHIFT, Escape, wakeup_monitor, eDP-1"
        ];

        # Single-fire bindings (prevent keyboard repeat spam when held)
        bindn = [
          # Shell / Spotlight launcher
          "SUPER, Space, spawn, dms ipc call spotlight toggle"

          # Wallpaper Carousel
          "SUPER, w, spawn, dms ipc wallpaperCarousel toggle"

          # DMS Inbuilt Wallpaper Changer
          "SUPER+ALT, w, spawn, dms ipc call dash toggle wallpaper"

          # Power menu (Ctrl + Alt + Del)
          "CTRL+ALT, Delete, spawn, dms ipc call powermenu toggle"

          # Layout cycling (Super + \)
          "SUPER, backslash, switch_layout"
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

            # Close window
            "ALT, F4, killclient"

            # =========================================================================
            # Workspace Overview (All 4 Modes Mapped to 'O')
            # =========================================================================
            "SUPER, o, toggleworkspaceoverview, all" # Grid: All workspaces (1-9)
            "SUPER+SHIFT, o, toggleworkspaceoverview, scroll_all" # Scrolling Strip: All workspaces
            "SUPER+CTRL, o, toggleworkspaceoverview, occupied" # Grid: Occupied workspaces only
            "SUPER+ALT, o, toggleworkspaceoverview, scroll_occupied" # Scrolling Strip: Occupied workspaces only

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
            "SUPER+ALT, f, togglemaximizescreen"
            "SUPER+SHIFT, f, togglefloating"
            "SUPER, g, toggleglobal"

            # Scratchpad (Minimize / Summon / Restore)
            "SUPER, m, minimized"
            "SUPER+ALT, m, toggle_scratchpad"
            "SUPER+SHIFT, m, restore_minimized, 0"

            # Directional focus (Vim & Arrow keys)
            "SUPER, h, focusdir, left"
            "SUPER, l, focusdir, right"
            "SUPER, k, focusdir, up"
            "SUPER, j, focusdir, down"
            "SUPER, Left, focusdir, left"
            "SUPER, Right, focusdir, right"
            "SUPER, Up, focusdir, up"
            "SUPER, Down, focusdir, down"

            # Relative tag shifting ([ and ])
            "SUPER, bracketleft, viewtoleft"
            "SUPER, bracketright, viewtoright"
            "SUPER+SHIFT, bracketleft, tagtoleft"
            "SUPER+SHIFT, bracketright, tagtoright"
          ]
          # =========================================================================
          # Tag / Workspace Navigation Quick Reference:
          #   Super + [1-9] or [ / ]         -> Switch view to tag
          #   Super + Shift + [1-9] or [ / ] -> Move window and follow to tag
          #   Super + Alt + [1-9]            -> Move window silently to tag
          #   Super + Ctrl + [1-9]           -> Toggle window pin/presence on tag
          # =========================================================================
          # Switch to workspace/tag 1-9 (Super + 1..9)
          ++ (map (i: "SUPER, ${toString i}, view, ${toString i}") (lib.range 1 9))
          # Move window and FOLLOW to workspace/tag 1-9 (Super + Shift + 1..9)
          ++ (map (i: "SUPER+SHIFT, ${toString i}, tag, ${toString i}") (lib.range 1 9))
          # Move window SILENTLY to workspace/tag 1-9 (Super + Alt + 1..9)
          ++ (map (i: "SUPER+ALT, ${toString i}, tagsilent, ${toString i}") (lib.range 1 9))
          # Toggle window presence on workspace/tag 1-9 (Super + Ctrl + 1..9)
          ++ (map (i: "SUPER+CTRL, ${toString i}, toggletag, ${toString i}") (lib.range 1 9));
      };
    };
  };
}
