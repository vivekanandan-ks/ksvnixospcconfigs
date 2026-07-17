{...}: {
  flake = {
    nixosModules.hyprland = {
      inputs,
      pkgs,
      #pkgs-unstable,
      ...
    }: {
      programs.hyprland = {
        enable = true;
        xwayland.enable = true; # default true
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      };
    };

    homeModules.nonDroid.hyprland = {
      inputs,
      lib,
      pkgs,
      self,
      #pkgs-unstable,
      ...
    }: {
      wayland.windowManager.hyprland = {
        enable = true;
        package = null;
        portalPackage = null;
        #configType = "lua";
        plugins = [
          #inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprbars
          inputs.hypr-dynamic-cursors.packages.${pkgs.stdenv.hostPlatform.system}.hypr-dynamic-cursors
          #inputs.gloview.packages.${pkgs.system}.gloview
        ];
        systemd.variables = ["--all"];

        settings = {
          exec-once = [
            "${lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.ksvNoctalia}"
          ];
          #bind = ["SUPER, TAB, gloview:toggle"];

          "plugin:dynamic-cursors" = {
            enabled = true;
            mode = "stretch";
          };
        };
      };
    };
  };
}
