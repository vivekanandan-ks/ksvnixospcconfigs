{
  inputs,
  self,
  ...
}: {
  flake-file.inputs = {
    base16-schemes = {
      url = "github:tinted-theming/schemes";
      flake = false;
    };
    stylix.url = "github:nix-community/stylix";
  };

  flake = {
    nixosModules.stylix = _: {
      imports = [
        inputs.stylix.nixosModules.stylix
      ];

      stylix = {
        enable = true;
        autoEnable = false; # Do not touch any system options or packages automatically
        homeManagerIntegration.autoImport = false; # Avoid duplicate imports & conflicts with Home Manager

        # Safe system targets with zero desktop breakage risk:
        targets.console.enable = true; # Themes early boot kernel VT palette via vt.default_* (for bootvine)
        targets.kmscon.enable = true; # Themes high-res TTYs (services.kmscon)
        targets.limine.enable = true; # Themes Limine bootloader terminal colors
        targets.limine.image.enable = false; # Preserves your custom wallpapers in limine-nixos-fp.nix

        base16Scheme = self.personas.ksv.themeScheme;
        polarity = self.personas.ksv.theme_polarity;
      };
    };

    homeModules.common.stylix = {
      pkgs,
      pkgs-unstable,
      ...
    }: {
      imports = [
        inputs.stylix.homeModules.stylix
      ];

      stylix.enable = true;

      stylix.icons = {
        enable = true;
        package = pkgs.fluent-icon-theme;
        dark = "Fluent-dark";
        light = "Fluent-light";
      };

      stylix.overlays.enable = false;
      #stylix.autoEnable = false;

      #stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-latte.yaml"; # light theme
      #stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-frappe.yaml";
      #stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
      #stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
      #stylix.base16Scheme = "${inputs.base16-schemes}/base16/catppuccin-mocha.yaml";
      stylix.base16Scheme = self.personas.ksv.themeScheme;

      stylix.opacity = {
        #applications = 0.7;
        terminal = 0.7;
        #desktop = 0.7;
        popups = 0.8;
      };

      stylix.polarity = self.personas.ksv.theme_polarity;

      stylix.fonts = {
        monospace = {
          package = self.personas.ksv.font.monospace.package pkgs-unstable;
          name = self.personas.ksv.font.monospace.name;
        };
        sizes = {
          applications = self.personas.ksv.font.sizes.applications;
          terminal = self.personas.ksv.font.sizes.terminal;
          desktop = self.personas.ksv.font.sizes.desktop;
          #popups = 18;
        };
      };

      stylix.targets.firefox.profileNames = ["default"];

      stylix.targets = {
        nushell.enable = true;

        kitty = {
          enable = true;
          colors.enable = false;
        };

        ghostty = {
          enable = false;
        };

        #zellij.enable = true;

        vscode = {
          enable = false;
        };

        qt.enable = false;

        kde = {
          enable = false;
          useWallpaper = false;
        };

        zed.enable = false;
        zen-browser.enable = false;

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
        opencode.enable = true;
        starship.enable = true;
        yazi.enable = true;
        zed.enable = true;

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
    };
  };
}
