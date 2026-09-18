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

      # Workaround for AMD APU "ring sdma0 timeout / [drm] device wedged" on sleep/DPMS wake.
      # Enable this if the screen stays black and Super+Shift+Esc fails to wake it,
      # or if `journalctl -b -k -g "device wedged"` reports GPU SDMA reset errors.
      # Disables Scatter-Gather display memory scanout on APU unified RAM.
      # "amdgpu.sg_display=0"
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
