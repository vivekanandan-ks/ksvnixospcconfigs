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
    settings = {
      #theme = "custom";
      #themes.custom.fg = "#ffffff";
      
    };
  };
}