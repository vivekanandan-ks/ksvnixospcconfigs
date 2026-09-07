_: {
  flake.nixosModules.vm-variant = {
    virtualisation.vmVariant = {
      virtualisation = {
        memorySize = 8192; # 8 GB RAM
        cores = 4; # 4 CPU Cores
        diskSize = 20480; # 20 GB Disk
        graphics = true; # Enable graphical window
        resolution = {
          x = 1920;
          y = 1080;
        };
        qemu.options = [
          "-device virtio-balloon" # Dynamic memory allocation
          "-vga virtio" # Virtio GPU acceleration
          "-display default,show-cursor=on" # Keep mouse cursor visible
        ];
      };

      # Overrides specifically for the test VM
      services.xserver.videoDrivers = ["modesetting"];
      services.displayManager.autoLogin.enable = true;
    };
  };
}
