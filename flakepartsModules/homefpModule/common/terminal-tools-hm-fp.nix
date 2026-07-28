{...}: {
  flake.homeModules.common.terminal-tools = {
    #inputs,
    #config,
    #lib,
    #pkgs,
    pkgs-unstable,
    #self,
    ...
  }: {
    home.packages = [pkgs-unstable.jj-starship];

    #carapace
    programs.carapace = {
      enable = true;
      package = pkgs-unstable.carapace;
      #enableNushellIntegration = true; # configured in nushell config so no need for this integration implementation
      enableBashIntegration = true;
      # enableFishIntegration = true;
      #fish already have it's own features so commenting this for now
    };


    #atuin - shell history and sync e2ee to my atuin account
    /*
    programs.atuin = {
      enable = true;
      package = pkgs-unstable.atuin;
      enableNushellIntegration = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      flags = [
        "--disable-up-arrow"
        #"--disable-ctrl-r"
      ];
      #check this out for settings options: https://docs.atuin.sh/configuration/config/
      settings = {
        auto_sync = true;
        sync_frequency = "1m";
        sync.records = true;
        search_mode = "fuzzy";
        style = "auto";
        inline_height = 40; # default 40
        show_preview = true;
        history_filter = [
          #"^z"
          "^clear"
          "^exit"
        ];
        theme = {
          name = "marine"; # options are ""(default) or "autumn" or "marine"(good out of the three)
          debug = true;
        };
      };
    };
    */

    #zoxide
    programs.zoxide = {
      enable = true;
      package = pkgs-unstable.zoxide;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      #options = [];
      #added an environment variable below in home.sessionVariables
    };
    home.sessionVariables = {
      _ZO_ECHO = 1; # zoxide show resolved directory
    };

    /*
    programs.tirith = {
      enable = true;
      package = pkgs-unstable.tirith;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
    */

    /*
    programs.intelli-shell = {
      enable = true;
      package = pkgs-unstable.intelli-shell;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;

    };
    */
  };
}
