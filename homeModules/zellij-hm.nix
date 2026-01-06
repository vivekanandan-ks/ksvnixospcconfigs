{
  #inputs,
  #config,
  #lib,
  #pkgs,
  pkgs-unstable,
  ...
}:

{
  programs.zellij = {
    enable = true;
    package = pkgs-unstable.zellij;
    enableBashIntegration = true;
    enableFishIntegration = true;
    show_startup_tips = false;
    ui = {
      pane_frames = {
        rounded_corners = true;
        #hide_session_name = false;
      };
    };
    settings = {
      #theme = "custom";
      #themes.custom.fg = "#ffffff";
      
    };
  };
}