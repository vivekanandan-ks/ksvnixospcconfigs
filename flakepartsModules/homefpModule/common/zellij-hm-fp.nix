_: {
  flake.homeModules.common.zellij = {
    #inputs,
    #config,
    #lib,
    #pkgs,
    pkgs-unstable,
    ...
  }: {
    programs.zellij = {
      enable = true;
      package = pkgs-unstable.zellij;
      enableBashIntegration = true;
      enableFishIntegration = true;

      settings = {
        default_mode = "locked";
        #theme = "custom";
        #themes.custom.fg = "#ffffff";

        show_startup_tips = false;
        pane_frames = true;
        ui = {
          pane_frames = {
            rounded_corners = true;
            #hide_session_name = false;
          };
        };
      };
    };
  };
}
