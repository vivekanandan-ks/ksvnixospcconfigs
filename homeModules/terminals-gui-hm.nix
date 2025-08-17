{
  #inputs,
  #config,
  #lib,
  #pkgs,
  pkgs-unstable,
  ...
}:

{

  # ghostty
  programs.ghostty = {
    enable = true;
    package = pkgs-unstable.ghostty;
    installBatSyntax = true;
    
      settings = {
        background-opacity = 0.8;
        background-blur = true;

        /*
        theme = "catppuccin-mocha";
        font-size = 10;
        keybind = [
          "ctrl+h=goto_split:left"
          "ctrl+l=goto_split:right"
        ];*/
      };
    
    /*themes = {
      catppuccin-mocha = {
        background = "1e1e2e";
        cursor-color = "f5e0dc";
        foreground = "cdd6f4";
        palette = [
          "0=#45475a"
          "1=#f38ba8"
          "2=#a6e3a1"
          "3=#f9e2af"
          "4=#89b4fa"
          "5=#f5c2e7"
          "6=#94e2d5"
          "7=#bac2de"
          "8=#585b70"
          "9=#f38ba8"
          "10=#a6e3a1"
          "11=#f9e2af"
          "12=#89b4fa"
          "13=#f5c2e7"
          "14=#94e2d5"
          "15=#a6adc8"
        ];
        selection-background = "353749";
        selection-foreground = "cdd6f4";
      };
    };*/
  };

  # kitty
  programs.kitty = {
    enable = true;
    package = pkgs-unstable.kitty;
    extraConfig = ''

      # cursor
      #cursor_shape  block
      cursor_trail  3
      cursor_trail_decay  0.1 0.4
      #cursor_blink_interval 0
      #cursor_trail_start_threshold 0
           
      # window
      background_opacity 0.8
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
