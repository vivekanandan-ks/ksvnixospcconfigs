{
  inputs,
  lib,
  ...
}: {
  # Intel Haswell (Gen 7.5) HD Graphics 4400 Hardware Video Acceleration
  flake.hostModules.ksvnixospc.jellyfin-encoding = lib.mkIf (inputs ? nixflix) {
    nixflix.jellyfin.encoding = {
      enableHardwareEncoding = true;
      hardwareAccelerationType = "vaapi";
      vaapiDevice = "/dev/dri/renderD128";

      # Haswell lacks hardware encode for HEVC and AV1
      allowHevcEncoding = false;
      allowAv1Encoding = false;

      # Codecs supported by Haswell Gen 7.5 VA-API
      hardwareDecodingCodecs = [
        "h264"
        "mpeg2video"
        "vc1"
      ];
    };
  };
}
