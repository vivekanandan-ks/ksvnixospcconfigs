_: {
  flake.hardwareModules.ksvnixospc.gpu = {
    pkgs-stable,
    lib,
    ...
  }: {
    # Intel Haswell (Gen 7.5) HD Graphics 4400 Hardware Video Acceleration
    hardware.graphics = {
      enable = true;
      # enable32Bit = true; # Only needed for Steam / Wine 32-bit gaming
      extraPackages = with pkgs-stable; [
        intel-vaapi-driver # Driver for Gen 7.5 Haswell (LIBVA_DRIVER_NAME=i965)
        libvdpau-va-gl
      ];
    };

    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = lib.mkDefault "i965";
    };

    # Intel Thermal Daemon (actively regulates Haswell RAPL power caps)
    services.thermald.enable = true;
  };
}
