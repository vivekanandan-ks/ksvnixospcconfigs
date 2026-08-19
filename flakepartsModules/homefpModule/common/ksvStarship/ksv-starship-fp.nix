_: {
  flake.homeModules.common.starship = {pkgs-unstable, ...}: {
    home.packages = [pkgs-unstable.jj-starship];

    programs.starship = {
      enable = true;
      package = pkgs-unstable.starship;
      #enableInteractive = false; #see HM option page before uncommenting
      enableNushellIntegration = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      settings = builtins.fromTOML (builtins.readFile ./starship-themes/pastel-powerline.toml);
      #settings = builtins.fromTOML (builtins.readFile ./starship-themes/catppuccin_macchiato.toml);
      #settings = builtins.fromTOML (builtins.readFile ./starship-themes/catppuccin_frappe.toml);
      #settings = builtins.fromTOML (builtins.readFile ./starship-themes/catppuccin_mocha.toml);
      #settings = builtins.fromTOML (builtins.readFile ./starship-themes/catppucin_latte.toml);
      #settings = builtins.fromTOML (builtins.readFile ./starship-themes/gruvbox-rainbow.toml);
      #settings = builtins.fromTOML (builtins.readFile ./starship-themes/tokyo-night.toml);
      #settings = builtins.fromTOML (builtins.readFile ./starship-themes/nerd-font-symbols.toml);
    };
  };
}
