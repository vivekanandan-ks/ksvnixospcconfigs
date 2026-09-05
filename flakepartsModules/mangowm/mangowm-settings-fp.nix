_: {
  flake = {
    homeModules.nonDroid.mangowc-settings = {lib, ...}: {
      wayland.windowManager.mango.settings = {
        # --- Trackpad / Input Settings ---
        trackpad_disable_while_typing = 1;

        # --- Blur & Visuals ---
        blur = 1;
        blur_layer = 1;
        blur_optimized = 1; # Only blur translucent areas, not full scene
        blur_params = {
          radius = 6;
          num_passes = 2;
          noise = 0.015;
          brightness = 0.9;
          contrast = 0.9;
          saturation = 1.1;
        };

        shadows = 1;
        shadow_only_floating = 1;
        layer_shadows = 0; # Disable compositor shadows on layer surfaces (prevents black boxes behind DMS popups)
        shadows_size = 12;
        shadows_blur = 16;

        border_radius = 12;
        borderpx = 0; # Borderless windows (no orange/colored borders)
        gappih = 0;
        gappiv = 0;
        gappoh = 0;
        gappov = 0;
        focused_opacity = 1.0;
        unfocused_opacity = 0.92;

        # --- Native Hot Corner ---
        enable_hotarea = 1;
        hotarea_corner = 2; # 0: top-left, 1: top-right, 2: bottom-left, 3: bottom-right
        hotarea_size = 10;

        # Enable returning to previous tag when toggling current tag (for desktop peek)
        view_current_to_back = 1;

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
        tag_animation_direction = 0; # 0: vertical, 1: horizontal

        # --- Layout Options & Cycling (All 14 Layouts) ---
        circle_layout = "scroller,tile,dwindle,grid,monocle,deck,center_tile,right_tile,vertical_scroller,vertical_tile,vertical_grid,vertical_deck,fair,vertical_fair";

        # --- Scroller Layout Options (Full Screen Height, No Empty Space) ---
        scroller_structs = 0;
        scroller_default_proportion = 1.0;
        scroller_default_proportion_single = 1.0;
        scroller_ignore_proportion_single = 0;

        # --- Layout Rules (Default to Scroller for tags 1-9) ---
        tagrule = map (i: "id:${toString i},layout_name:scroller") (lib.range 1 9);

        # --- Window Rules ---
        windowrule = [
          "focused_opacity:0.90,unfocused_opacity:0.75,appid:.*dolphin.*"
        ];
      };
    };
  };
}
