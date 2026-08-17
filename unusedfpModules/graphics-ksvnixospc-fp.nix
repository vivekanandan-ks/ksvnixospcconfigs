_: {
  flake.nixosModules.ksvnixospcGraphics = {pkgs, ...}: {
    # Enable Intel & NVIDIA Dual-GPU hardware acceleration and PRIME offloading
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-vaapi-driver # VA-API hardware video acceleration for Haswell iGPU (LIBVA_DRIVER_NAME=i965)
      ];
    };

    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "i965";
      DRI_PRIME = "1"; # Offload 3D/OpenGL rendering to NVIDIA dGPU globally by default
    };
  };
}
