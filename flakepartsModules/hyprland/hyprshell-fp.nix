_: {
  flake-file.inputs = {
    hyprshell = {
      url = "github:H3rmt/hyprshell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

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
              filter_by = ["current_monitor"];
              switch_workspaces = false;
            };
            overview = {
              enable = false;
            };
          };
        };
      };

      systemd.user.services.hyprshell = {
        Unit = {
          PartOf = lib.mkForce ["hyprland-session.target"];
          After = lib.mkForce ["hyprland-session.target"];
        };
        Install.WantedBy = lib.mkForce ["hyprland-session.target"];
      };
    };
  };
}
