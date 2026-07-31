{...}: {
  flake = {
    homeModules.nonDroid.hyprmoncfg = { pkgs-unstable, ... }: {
      
      home.packages = [
        pkgs-unstable.hyprmoncfg
        pkgs-unstable.hyprmon
      ];

      wayland.windowManager.hyprland.settings = {
        bind = [
          "SUPER, P, exec, kitty -- hyprmon"
          "SUPER SHIFT, P, exec, kitty -- hyprmoncfg"
        ];
      };

      systemd.user.services.hyprmoncfgd = {
        Unit = {
          Description = "Hyprmoncfg Monitor Daemon";
          PartOf = [ "hyprland-session.target" ];
          After = [ "hyprland-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs-unstable.hyprmoncfg}/bin/hyprmoncfgd";
          # Do not restart automatically so it doesn't spin loop when failing
          Restart = "no";
        };
        Install = {
          WantedBy = [ "hyprland-session.target" ];
        };
      };

    };
  };
}
