_: {
  flake.nixosModules.ksvnixospcGraphics = {pkgs, ...}: {
    # Enable hardware graphics acceleration
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-vaapi-driver # VA-API hardware video acceleration for Haswell iGPU (LIBVA_DRIVER_NAME=i965)
      ];
    };

    # Keep desktop UI & Wayland compositor on Intel iGPU for smooth 60fps and zero-latency cursor,
    # while enabling VA-API hardware video acceleration.
    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "i965";
    };

    # Provide a system-wide 'nvrun' utility to easily offload heavy apps/games to NVIDIA GPU on demand
    # Usage: nvrun <application> (e.g., nvrun blender, nvrun steam, nvrun glxgears)
    environment.systemPackages = with pkgs; [
      (writeShellScriptBin "nvrun" ''
        exec env DRI_PRIME=1 "$@"
      '')
    ];
  };
}
