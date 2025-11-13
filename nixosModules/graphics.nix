# graphics.nix
{
  #config,
  #lib,
  pkgs,
  ...
}:

{

  # Enable intel graphics harware acceleration (this is supposed to solve the CPUoverheating issues while using camera)
  # refer this: https://wiki.nixos.org/wiki/Accelerated_Video_Playback#Intel
  # refer: https://discourse.nixos.org/t/help-to-solve-cpu-peaks-overheats-while-using-camera-possibly-hw-acceleration-i-guess/68591/1
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      #intel-media-driver # For Broadwell (2014) or newer processors. LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # For older processors. LIBVA_DRIVER_NAME=i965
      #intel-ocl # looks like this is useful for running LLMs
    ];
  };
  environment.sessionVariables = {
    #LIBVA_DRIVER_NAME = "iHD";
    LIBVA_DRIVER_NAME = "i965";
  }; # Optionally, set the environment variable

}
/*
  let
    # Put your real IDs here; these should not be the same in practice
    gpuBusId = {
      # find the below values using the following command
      # nix --experimental-features "flakes nix-command" run github:eclairevoyant/pcids
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:4:0:0";
    };

    gpuPaths =
      let
        pciPath =
          xorgBusId:
          let
            components = lib.drop 1 (lib.splitString ":" xorgBusId);
            toHex = i: lib.toLower (lib.toHexString (lib.toInt i));

            domain = "0000"; # Apparently the domain is always set to 0000
            bus = lib.fixedWidthString 2 "0" (toHex (builtins.elemAt components 0));
            device = lib.fixedWidthString 2 "0" (toHex (builtins.elemAt components 1));
            function = toHex (builtins.elemAt components 2);
          in
          "dri/by-path/pci-${domain}:${bus}:${device}.${function}-card";
      in
      {
        intel = pciPath gpuBusId.intelBusId;
        nvidia = pciPath gpuBusId.nvidiaBusId;
      };
  in
  {
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware = {
      nvidia = {
        # Depending on which GPU you actually have
        package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
        #package = config.boot.kernelPackages.nvidiaPackages.legacy_390;
        videoAcceleration = false;
      };

      graphics = {
        enable = true;
        extraPackages = [
          pkgs.intel-vaapi-driver
        ];
      };
    };

    # Note that this is using `.variables` not `.sessionVariables` now;
    # Double check that this is still set correctly when you start your terminal
    environment.variables = {
      LIBVA_DRIVER_NAME = "i965";
      KWIN_DRM_DEVICES = gpuPaths.nvidia;
    };
  }
*/
