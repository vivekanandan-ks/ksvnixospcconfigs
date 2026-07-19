{...}: {
  flake = {
    homeModules.nonDroid.hyprshell = {
      inputs,
      lib,
      pkgs,
      pkgs-unstable,
      ...
    }: {
      imports = [
        inputs.hyprshell.homeModules.default
      ];

      programs.hyprshell = {
        enable = true;
        package = inputs.hyprshell.packages.${pkgs.stdenv.hostPlatform.system}.default;
        systemd.enable = true;
        
        settings = {
          windows = {
            enable = true;
            switch = {
              enable = true;
              key = "Tab";
              modifier = "alt";
              filter_by = [ "current_monitor" ];
              switch_workspaces = false;
            };
            overview = {
              enable = true;
            };
          };
        };
      };
    };
  };
}
