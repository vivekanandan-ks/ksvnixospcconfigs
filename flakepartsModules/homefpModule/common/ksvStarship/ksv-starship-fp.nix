_: {
  flake.homeModules.common.starship = {pkgs-unstable, ...}: {
    home.packages = [pkgs-unstable.jj-starship];

    programs.starship = let
      starship-themes-folder = ./starship-themes;
    in {
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
      #settings = builtins.fromTOML (builtins.readFile "${starship-themes-folder}/catppuccin_mocha.toml");
      #settings = builtins.fromTOML (builtins.readFile "${starship-themes-folder}/catppucin_latte.toml");
      #settings = builtins.fromTOML (builtins.readFile "${starship-themes-folder}/gruvbox-rainbow.toml");
      #settings = builtins.fromTOML (builtins.readFile "${starship-themes-folder}/tokyo-night.toml");
      #settings = builtins.fromTOML (builtins.readFile "${starship-themes-folder}/nerd-font-symbols.toml");
    };
  };
}
