{
  pkgs, 
  ...
}:

{
  stylix.enable = true;

  
  #stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-latte.yaml"; # light theme
  #stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-frappe.yaml";
  #stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  #stylix.image = ./hmResources/frieren.png;

  stylix.opacity = {
    #applications = 0.7;
    terminal = 0.7;
    #desktop = 0.7;
    #popups = 0.7;
  };

  stylix.polarity = "dark";

  stylix.fonts.sizes = {
    applications = 10;
    terminal = 11;
    desktop = 9;
    #popups = 18;
  };

  #stylix.targets.nushell.enable = false;
  #stylix.targets.nushell.colors.enable = false;

  #stylix.targets.kitty.enable = false;
  stylix.targets.kitty.colors.enable = false;
  stylix.targets.ghostty.colors.enable = false;
  stylix.targets.wezterm.colors.enable = false;
  #stylix.targets.vscode.colors.enable = false;
  stylix.targets.vscode.enable = false;
  stylix.targets.kde.enable = false;
  stylix.targets.nixos-icons.enable = false;

  # helix have lib.mkForce option for the custom theme which 
  # overrides the stylix theme (coz theming via isnt that good for helix)

}