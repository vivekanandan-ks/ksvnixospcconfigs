{
  #inputs,
  #config,
  #lib,
  #pkgs,
  pkgs-unstable,
  ...
}:

{

  #carapace
  programs.carapace = {
    enable = true;
    package = pkgs-unstable.carapace;
    #enableNushellIntegration = true; # configured in nushell config so no need for this integration implementation
    enableBashIntegration = true;
    # enableFishIntegration = true;
    #fish already have it's own features so commenting this for now
  };

  #starship
  programs.starship =
    let

      starship-themes-folder = ./hmResources/starship-themes;

    in
    {
      enable = true;
      package = pkgs-unstable.starship;
      #enableInteractive = false; #see HM option page before uncommenting
      enableNushellIntegration = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      #uncomment only on eof the following settings
      settings = builtins.fromTOML (builtins.readFile "${starship-themes-folder}/pastel-powerline.toml");
      #settings = builtins.fromTOML (builtins.readFile "${starship-themes-folder}/catppuccin_macchiato.toml");
      #settings = builtins.fromTOML (builtins.readFile "${starship-themes-folder}/catppuccin_frappe.toml");
      #settings = builtins.fromTOML (builtins.readFile "${starship-themes-folder}/catppuccin_mocha");
      #settings = builtins.fromTOML (builtins.readFile "${starship-themes-folder}/catppuccin_latte.toml");
      #settings = builtins.fromTOML (builtins.readFile "${starship-themes-folder}/gruvbox-rainbow.toml);
      #settings = builtins.fromTOML (builtins.readFile "${starship-themes-folder}/tokyo-night.toml");
      #settings = builtins.fromTOML (builtins.readFile "${starship-themes-folder}/nerd-font-symbols.toml");

    };

  #atuin - shell history and sync e2ee to my atuin account
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
        "^z"
        "^clear"
        "^exit"
      ];
      theme = {
        name = "marine"; # options are ""(default) or "autumn" or "marine"(good out of the three)
        debug = true;
      };
    };
  };

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
    programs.intelli-shell = {
      enable = true;
      package = pkgs-unstable.intelli-shell;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;

    };
  */

}
