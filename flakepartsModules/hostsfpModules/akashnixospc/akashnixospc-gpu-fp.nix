_: {
  flake.hardwareModules.akashnixospc.gpu = {
    pkgs,
    lib,
    ...
  }: {
    # Early KMS (Kernel Mode Setting): Load amdgpu in initramfs stage 1
    # Prevents race conditions where display-manager/compositor starts before /dev/dri is ready
    boot.initrd.kernelModules = ["amdgpu"];

    # Prevent eDP internal panel wake/DPMS failures on AMD Ryzen APUs
    boot.kernelParams = [
      "amdgpu.dcdebugmask=0x10"
    ];

    # AMD GPU hardware acceleration (Radeon 610M / RDNA2)
    hardware.graphics = {
      enable = true;
      # enable32Bit = true; # Only needed for Steam / Wine 32-bit gaming
      extraPackages = with pkgs; [
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };

    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = lib.mkForce "radeonsi";
      VDPAU_DRIVER = lib.mkForce "radeonsi";
    };
  };
}
