{
  inputs,
  lib,
  ...
}: {
  flake.nixosModules.selfHosting = lib.mkIf (inputs ? nixflix) {
    nixflix.navidrome = {
      enable = true;
      group = "media";

      users = {
        admin = {
          userName = "admin";
          isAdmin = true;
          password = "admin123";
        };
      };

      settings = {
        Port = 4533;
        Address = "0.0.0.0";
        MusicFolder = "/data/media/music";
        ScanSchedule = "@every 1h";
      };
    };

    networking.firewall.allowedTCPPorts = [ 4533 ];
  };
}
