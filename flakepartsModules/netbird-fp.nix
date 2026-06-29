{ ... }: {
  flake = {
    nixosModules.netbird = { pkgs, pkgs-unstable, ... }: {
      services.netbird = {
        enable = true;
        package = pkgs-unstable.netbird;
        ui = {
          enable = true;
          package = pkgs-unstable.netbird-ui;  
        };
      };
    };

    homeModules.nonDroid.netbird-ui = { pkgs-unstable, ... }: {
      systemd.user.services.netbird-ui = {
        Unit = {
          Description = "Netbird UI";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs-unstable.netbird-ui}/bin/netbird-ui";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };
  };
}