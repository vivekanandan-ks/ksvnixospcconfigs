{
  inputs,
  lib,
  ...
}: {
  # Declare disko input using flake-file
  flake-file.inputs.disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # Import disko flake-parts module
  imports = lib.optionals (inputs ? disko) [
    inputs.disko.flakeModules.default
  ];

  flake = lib.optionalAttrs (inputs ? disko) {
    # Disko Configurations flake output (used by disko & disko-install CLI)
    diskoConfigurations = {
      ksvnixospc = {
        disko.devices = {
          disk = {
            main = {
              type = "disk";
              device = "/dev/disk/by-id/ata-ST1000LM024_HN-M101MBB_S30YJ9CD827863";
              content = {
                type = "gpt";
                partitions = {
                  ESP = {
                    priority = 1;
                    type = "EF00";
                    size = "2G";
                    content = {
                      type = "filesystem";
                      format = "vfat";
                      mountpoint = "/boot";
                      mountOptions = [
                        "fmask=0077"
                        "dmask=0077"
                      ];
                    };
                  };
                  root = {
                    size = "210G";
                    content = {
                      type = "filesystem";
                      format = "ext4";
                      mountpoint = "/";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
