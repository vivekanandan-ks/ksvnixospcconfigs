_: {
  flake.hardwareModules.deejunixospc.gpu = {
    pkgs-stable,
    lib,
    ...
  }: {
    # Intel Kaby Lake (Gen 9.5) HD Graphics 620 Hardware Video Acceleration
    hardware.graphics = {
      enable = true;
      # enable32Bit = true; # Only needed for Steam / Wine 32-bit gaming
      extraPackages = with pkgs-stable; [
        intel-media-driver # Modern iHD driver for Gen 8+ (Broadwell, Skylake, Kaby Lake)
        intel-vaapi-driver # Legacy fallback
        libvdpau-va-gl
      ];
    };

    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = lib.mkDefault "iHD";
    };

    # Intel Thermal Daemon (proactively monitors & caps thermals on this Intel CPU)
    services.thermald.enable = true;
  };
}
