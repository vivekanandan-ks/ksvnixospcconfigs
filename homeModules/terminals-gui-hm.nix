{
  #inputs,
  #config,
  #lib,
  #pkgs,
  pkgs-unstable,
  ...
}: {
  # ghostty
  programs.ghostty = {
    enable = true;
    package = pkgs-unstable.ghostty;
    installBatSyntax = true;

    settings = {
      #background-opacity = 0.8;
      background-blur = true;
      custom-shader = [
        "${./hmResources/ghostty-shaders/cursor_smear.glsl}"
        #"${./hmResources/ghostty-shaders/cursor_blaze.glsl}"
        #"${./hmResources/ghostty-shaders/animated-gradient-shader.glsl}"
        #"${./hmResources/ghostty-shaders/cursor_smear_gradient.glsl}"
      ];
      #fullscreen = true;

      #theme = "carbonfox"; # "citruszest" "Dark Pastel" "Hurtado" "Oxocarbon" # showing error
      #font-size = 10;
      #keybind = [
      #  "ctrl+h=goto_split:left"
      #  "ctrl+l=goto_split:right"
      #];
    };
  };

  # kitty
  programs.kitty = {
    enable = true;
    package = pkgs-unstable.kitty;
    settings = {
      hide_window_decorations = "yes";
      shell = "${pkgs-unstable.zellij}/bin/zellij";
    };
    extraConfig = ''

      # cursor
      #cursor_shape  block
      cursor_trail  3
      cursor_trail_decay  0.1 0.4
      #cursor_blink_interval 0
      #cursor_trail_start_threshold 0

      # window
      #background_opacity 0.7
      background_blur 1
      dynamic_background_opacity yes

      # terminal bell
      enable_audio_bell no
      visual_bell_duration 1
      window_alert_on_bell yes
      bell_on_tab "🔔 "

    '';
  };

  /*
  # waveterm - modern terminal app
  programs.waveterm = {
    enable = true;
    package = pkgs-unstable.waveterm;

    bookmarks = {
      "bookmark@google" = {
        title = "Google";
        url = "https://www.google.com";
      };
    };

    settings = {
      #"window:blur" = true;
      #"window:opacity" = 0.5;
    };
  };
  */
}
