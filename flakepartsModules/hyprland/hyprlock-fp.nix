{...}: {
  flake = {
    homeModules.nonDroid.hyprlock = {
      pkgs-unstable,
      ...
    }: {
      programs.hyprlock = {
        enable = true;
        package = pkgs-unstable.hyprlock;
        settings = {
          general = {
            disable_loading_bar = false;
            hide_cursor = false;
            grace = 0;
            no_fade_in = false;
          };

          background = [
            {
              monitor = "";
              path = "screenshot";
              blur_passes = 3;
              blur_size = 8;
              brightness = 0.5;
              vibrancy = 0.2;
              vibrancy_darkness = 0.2;
            }
          ];

          image = [
            {
              monitor = "";
              path = "${../noctalia/shoyohinata.png}";
              size = 150;
              border_size = 4;
              border_color = "rgb(255, 255, 255)";
              rounding = -1; # Circle
              position = "0, 150";
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
              outer_color = "rgba(255, 255, 255, 0.1)";
              inner_color = "rgba(255, 255, 255, 0.1)";
              font_color = "rgb(255, 255, 255)";
              fade_on_empty = false; # Let's keep it visible since it's styled nicely
              fade_timeout = 1000;
              placeholder_text = "<i>Enter Password...</i>";
              hide_input = false;
              rounding = -1;
              check_color = "rgb(204, 136, 34)";
              fail_color = "rgb(204, 34, 34)";
              fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
              capslock_color = "rgb(34, 136, 204)";
              position = "0, -70";
              halign = "center";
              valign = "center";
            }
          ];

          label = [
            # Time
            {
              monitor = "";
              text = "$TIME";
              color = "rgba(255, 255, 255, 1.0)";
              font_size = 100;
              font_family = "Inter Display Bold";
              position = "0, 100";
              halign = "center";
              valign = "top";
            }
            # Date
            {
              monitor = "";
              text = "cmd[update:1000] echo \"<b>$(date +'%A, %B %d')</b>\"";
              color = "rgba(255, 255, 255, 1.0)";
              font_size = 22;
              font_family = "Inter";
              position = "0, 50";
              halign = "center";
              valign = "top";
            }
            # Greeting
            {
              monitor = "";
              text = "Welcome back, $USER";
              color = "rgba(255, 255, 255, 1.0)";
              font_size = 20;
              font_family = "Inter Medium";
              position = "0, 20";
              halign = "center";
              valign = "center";
            }
          ];
        };
      };
    };
  };
}
