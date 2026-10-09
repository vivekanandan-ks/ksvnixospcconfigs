{
  inputs,
  lib,
  ...
}: {
  flake.nixosModules.selfHosting = lib.mkIf (inputs ? nixflix) (
    let
      port = 4533;
    in
    {
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
          Port = port;
          Address = "0.0.0.0";
          MusicFolder = "/data/media/music";
          ScanSchedule = "@every 1h";
        };
      };

      localAliases."navidrome.local" = port;

      networking.firewall.allowedTCPPorts = [ port ];
    }
  );
}
