# Placeholder for hardware configuration
{...}: {
  # A dummy root filesystem is required for NixOS to evaluate successfully.
  # You will replace this file completely with your generated hardware-configuration.nix later.
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/00000000-0000-0000-0000-000000000000";
    fsType = "ext4";
  };
}
