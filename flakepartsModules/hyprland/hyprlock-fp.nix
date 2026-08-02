{...}: {
  flake = {
    homeModules.nonDroid.hyprlock = {
      pkgs-unstable,
      lib,
      ...
    }: {
      programs.hyprlock = {
        enable = true;
        package = pkgs-unstable.hyprlock;
      };

      programs.hyprlock.settings = lib.mkForce {
          general = {
            disable_loading_bar = false;
            hide_cursor = false;
            #grace = 0;
            no_fade_in = false;
            #fractional_scaling = 0; # Fixes the zoomed-in UI bug
          };

          background = lib.mkForce [
            {
              monitor = "";
              path = "screenshot";
              blur_passes = 3;
              blur_size = 8;
              brightness = 0.8;
              vibrancy = 0.2;
              vibrancy_darkness = 0.0;
            }
          ];

          image = [
            {
              monitor = "";
              path = "${../noctalia/shoyohinata.png}";
              size = 250;
              border_size = 4;
              border_color = "rgb(255, 255, 255)";
              rounding = -1; # Circle
              position = "0, 0";
              halign = "center";
              valign = "center";
            }
          ];

          input-field = [
            {
              monitor = "";
              size = "250, 50";
              outline_thickness = 3;
              dots_size = 0.26;
              dots_spacing = 0.15;
              dots_center = true;
              dots_rounding = -1;
              dots_text_format = "🫣";
              outer_color = "rgba(255, 255, 255, 0.1)";
              inner_color = "rgba(255, 255, 255, 0.1)";
              font_color = "rgb(255, 255, 255)";
              fade_on_empty = false;
              fade_timeout = 1000;
              placeholder_text = "<i>Enter Password...</i>";
              hide_input = false;
              rounding = -1;
              check_color = "rgb(204, 136, 34)";
              fail_color = "rgb(204, 34, 34)";
              fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
              capslock_color = "rgb(34, 136, 204)";
              position = "0, -180";
              halign = "center";
              valign = "center";
            }
          ];

          label = [
            # Time
            {
              monitor = "";
              text = "cmd[update:1000] echo \"$(date +'%H:%M:%S')\"";
              color = "rgba(255, 255, 255, 1.0)";
              font_size = 80;
              font_family = "Inter Display Bold";
              position = "0, 300";
              halign = "center";
              valign = "center";
            }
            # Date
            {
              monitor = "";
              text = "cmd[update:1000] echo \"<b>$(date +'%A, %B %d, %Y')</b>\"";
              color = "rgba(255, 255, 255, 1.0)";
              font_size = 22;
              font_family = "Inter";
              position = "0, 200";
              halign = "center";
              valign = "center";
            }
          ];
        };
    };
  };
}
