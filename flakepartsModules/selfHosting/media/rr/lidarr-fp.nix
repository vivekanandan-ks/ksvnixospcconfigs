{
  inputs,
  lib,
  ...
}: {
  flake.nixosModules.selfHosting = lib.mkIf (inputs ? nixflix) {
    nixflix.lidarr = {
      enable = true;
      group = "media";
      mediaDirs = [ "/data/media/music" ];
      config = {
        apiKey = "f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0";
        hostConfig = {
          port = 8686;
          username = "admin";
          password = "admin123";
          authenticationRequired = "disabledForLocalAddresses";
        };
      };
      # Default quality profile is "Any" with Lossless cutoff and upgradeAllowed = true
    };

    networking.firewall.allowedTCPPorts = [ 8686 ];
  };
}
