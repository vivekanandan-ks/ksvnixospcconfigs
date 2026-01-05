{pkgs, ...}: {
  stylix.enable = true;
  #stylix.autoEnable = false;

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

  stylix.targets.firefox.profileNames = [ "default" ];

  stylix.targets = {
    kitty = {
      enable = true;
      colors.enable = false;
    };

    ghostty = {
      enable = true;
      colors.enable = false;
    };

    vscode = {
      enable = false;
    };

    qt.enable = false;

    /*
      bat.enable = true;
    btop.enable = true;
    vesktop.enable = true;
    fish.enable = true;
    fzf.enable = true;
    gdu.enable = true;
    gedit.enable = true;
    gitui.enable = true;
    k9s.enable = true;
    kubecolor.enable = true;
    lazygit.enable = true;
    micro.enable = true;
    mpv.enable = true;
    nvf.enable = true;
    nixos-icons.enable = true;
    nushell.enable = true;
    opencode.enable = true;
    starship.enable = true;
    yazi.enable = true;
    zed.enable = true;
    zellij.enable = true;
    zen-browser.enable = true;
    kde.enable = true;
    gtk.enable = true;
    #qt.enable = true;
    */
  };

  #stylix.targets.nushell.enable = false;
  #stylix.targets.nushell.colors.enable = false;

  #stylix.targets.kitty.enable = false;
  #stylix.targets.kitty.colors.enable = false;
  #stylix.targets.ghostty.colors.enable = false;
  #stylix.targets.wezterm.colors.enable = false;
  #stylix.targets.vscode.colors.enable = false;
  #stylix.targets.vscode.enable = false;
  #stylix.targets.kde.enable = false;
  #stylix.targets.nixos-icons.enable = false;

  # helix have lib.mkForce option for the custom theme which
  # overrides the stylix theme (coz theming via isnt that good for helix)
}
