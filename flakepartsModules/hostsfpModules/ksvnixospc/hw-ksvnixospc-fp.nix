{
  inputs,
  lib,
  ...
}: {
  # Disko's default declarative mode mounts partitions via /dev/disk/by-partlabel/disk-main-root. Because your existing disk lacked PARTLABEL
  # headers, Linux couldn't locate /dev/disk/by-partlabel/disk-main-root during boot.
  # sudo nix shell nixpkgs#gptfdisk --command sgdisk --change-name=1:disk-main-ESP --change-name=2:disk-main-root /dev/sda

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
                  data524G = {
                    size = "488.3G";
                    content = {
                      type = "filesystem";
                      format = "ntfs";
                    };
                  };
                  data237G = {
                    size = "100%";
                    content = {
                      type = "filesystem";
                      format = "ntfs";
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
