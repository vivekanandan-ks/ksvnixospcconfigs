_: {
  flake.hardwareModules.akashnixospc.gpu = {
    pkgs,
    lib,
    ...
  }: {
    # Prevent eDP internal panel wake/DPMS failures on AMD Ryzen APUs
    boot.kernelParams = [
      "amdgpu.dcdebugmask=0x10"
    ];

    # AMD GPU hardware acceleration (Radeon 610M / RDNA2)
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
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
