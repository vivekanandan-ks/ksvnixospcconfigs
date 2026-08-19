{inputs, ...}: {
  flake-file.inputs = {
    mango = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake = {
    # 1. NixOS System Configuration (for Ly session entry & portals)
    nixosModules.mangowc = {...}: {
      imports = [
        inputs.mango.nixosModules.mango
      ];

      programs.mango = {
        enable = true;
        addLoginEntry = true;
      };
    };

    # 2. Home Manager Configuration (for settings, DMS, & systemd targets)
    homeModules.nonDroid.mangowc = {
      config,
      lib,
      ...
    }: {
      imports = [
        inputs.mango.hmModules.mango
      ];

      wayland.windowManager.mango = {
        enable = true;
        systemd = {
          enable = true; # Starts mango-session.target for DMS / notifications
          variables = [
            "DISPLAY"
            "WAYLAND_DISPLAY"
            "XDG_CURRENT_DESKTOP"
            "XDG_SESSION_TYPE"
            "NIXOS_OZONE_WL"
            "XCURSOR_THEME"
            "XCURSOR_SIZE"
            "QT_QPA_PLATFORM"
            "QT_QPA_PLATFORMTHEME"
            "QT_STYLE_OVERRIDE"
            "XDG_MENU_PREFIX"
          ];
          extraCommands = [
            "systemctl --user reset-failed"
            "systemctl --user start mango-session.target"
            "systemctl --user restart xremap || true"
          ];
        };
        autostart_sh = ''
          export QT_QPA_PLATFORM="wayland;xcb"
          export QT_QPA_PLATFORMTHEME="kde"
          export QT_STYLE_OVERRIDE="breeze"
          export XDG_MENU_PREFIX="plasma-"
        '';

        settings = {
          blur = 1;
          blur_layer = 1;
          blur_optimized = 0; # Full scene blur (ensures fullscreen & stacked windows have frosted glass blur)
          blur_params_radius = 6;
          blur_params_num_passes = 2;
          blur_params_noise = 0.02;
          blur_params_brightness = 0.9;
          blur_params_contrast = 0.9;
          blur_params_saturation = 1.2;

          shadows = 1;
          layer_shadows = 0; # Disable compositor shadows on layer surfaces (prevents black boxes behind DMS popups)
          shadow_only_floating = 1;
          shadows_size = 12;
          shadows_blur = 16;

          border_radius = 12;
          borderpx = 0; # Borderless windows (no orange/colored borders)
          gappih = 5;
          gappiv = 5;
          gappoh = 5;
          gappov = 5;
          focused_opacity = 1.0;
          unfocused_opacity = 0.92;

          # --- Animations (Smooth Zoom & Fade, No Slide) ---
          animations = 1;
          layer_animations = 1;
          animation_type_open = "zoom";
          animation_type_close = "zoom";
          layer_animation_type_open = "zoom";
          layer_animation_type_close = "zoom";
          animation_fade_in = 1;
          animation_fade_out = 1;
          fadein_begin_opacity = 0.4;
          zoom_initial_ratio = 0.5;
          zoom_end_ratio = 0.8;
          animation_duration_open = 350;
          animation_duration_close = 250;
          animation_duration_move = 400;
          animation_curve_open = "0.46,1.0,0.29,0.99";
          animation_curve_move = "0.46,1.0,0.29,0.99";
          tag_animation_direction = 1;

          # --- Layout Options & Cycling ---
          circle_layout = "scroller,tile,dwindle,grid,monocle,deck,center_tile,vertical_scroller,right_tile";

          # --- Scroller Layout Options (Full Screen Height, No Empty Space) ---
          scroller_structs = 0;
          scroller_default_proportion = 1.0;
          scroller_default_proportion_single = 1.0;
          scroller_ignore_proportion_single = 0;

          # --- Layout Rules (Default to Scroller) ---
          tagrule = [
            "id:1,layout_name:scroller"
            "id:2,layout_name:scroller"
            "id:3,layout_name:scroller"
            "id:4,layout_name:scroller"
            "id:5,layout_name:scroller"
            "id:6,layout_name:scroller"
            "id:7,layout_name:scroller"
            "id:8,layout_name:scroller"
            "id:9,layout_name:scroller"
          ];

          # --- Keybindings ---
          bind = [
            # Layout switching (Direct: Alt + Shift + 1-9)
            "ALT+SHIFT, 1, setlayout, scroller"
            "ALT+SHIFT, 2, setlayout, tile"
            "ALT+SHIFT, 3, setlayout, dwindle"
            "ALT+SHIFT, 4, setlayout, grid"
            "ALT+SHIFT, 5, setlayout, monocle"
            "ALT+SHIFT, 6, setlayout, deck"
            "ALT+SHIFT, 7, setlayout, center_tile"
            "ALT+SHIFT, 8, setlayout, vertical_scroller"
            "ALT+SHIFT, 9, setlayout, right_tile"

            # Layout cycling (Super + \)
            "SUPER, backslash, switch_layout"

            # Close window
            "ALT, F4, killclient"

            # Shell / Spotlight launcher
            "SUPER, Space, spawn, dms ipc call spotlight toggle"

            # Power menu (Ctrl + Alt + Del)
            "CTRL+ALT, Delete, spawn, dms ipc call powermenu toggle"

            # Window overview (Mission control)
            "SUPER, Tab, toggleoverview"

            # Window cycling (Alt + Tab)
            "ALT, Tab, focusstack, next"
            "ALT+SHIFT, Tab, focusstack, prev"
            "ALT, grave, focuslast"

            # Window states
            "SUPER, f, togglefullscreen"
            "SUPER, s, togglefloating"

            # Directional focus
            "SUPER, h, focusdir, left"
            "SUPER, l, focusdir, right"
            "SUPER, k, focusdir, up"
            "SUPER, j, focusdir, down"

            # Tag / Workspace navigation
            "SUPER, 1, view, 1"
            "SUPER, 2, view, 2"
            "SUPER, 3, view, 3"
            "SUPER, 4, view, 4"
            "SUPER, 5, view, 5"
            "SUPER, 6, view, 6"
            "SUPER, 7, view, 7"
            "SUPER, 8, view, 8"
            "SUPER, 9, view, 9"

            # Move window to tag
            "SUPER+SHIFT, 1, tag, 1"
            "SUPER+SHIFT, 2, tag, 2"
            "SUPER+SHIFT, 3, tag, 3"
            "SUPER+SHIFT, 4, tag, 4"
            "SUPER+SHIFT, 5, tag, 5"
            "SUPER+SHIFT, 6, tag, 6"
            "SUPER+SHIFT, 7, tag, 7"
            "SUPER+SHIFT, 8, tag, 8"
            "SUPER+SHIFT, 9, tag, 9"
          ];
        };
      };

      # Systemd-managed clipboard history daemon for MangoWC
      services.cliphist = lib.mkIf (config.wayland.windowManager.mango.enable or false) {
        enable = true;
        allowImages = true;
        systemdTargets = ["mango-session.target"];
      };
    };
  };
}
