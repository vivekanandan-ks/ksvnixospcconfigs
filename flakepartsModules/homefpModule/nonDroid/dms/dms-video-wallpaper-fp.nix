{
  self,
  ...
}: {
  flake.homeModules.nonDroid.dms-video-wallpaper = {
    lib,
    pkgs,
    ...
  }: let
    videoFolder = self.personas.ksv.currentVideoWallpaperSet;
    videoFiles = builtins.attrNames (builtins.readDir videoFolder);
    defaultVideo = builtins.head videoFiles;

    # Pre-generate cycling settings for all possible physical display outputs:
    # - Laptop internal screens: eDP-1, eDP-2
    # - HDMI outputs: HDMI-A-1..10, HDMI-1..10
    # - DisplayPort / Type-C: DP-1..10
    # - USB-C MST Hubs / Docks: DP-1-1..DP-4-5
    # - Projectors / Adapters: DVI-D-1..4, VGA-1..4
    physicalDisplayKeys =
      [ "eDP-1" "eDP-2" ]
      ++ (map (i: "HDMI-A-${toString i}") (lib.range 1 10))
      ++ (map (i: "HDMI-${toString i}") (lib.range 1 10))
      ++ (map (i: "DP-${toString i}") (lib.range 1 10))
      ++ (lib.concatMap (p: map (i: "DP-${toString p}-${toString i}") (lib.range 1 5)) (lib.range 1 4))
      ++ (map (i: "DVI-D-${toString i}") (lib.range 1 4))
      ++ (map (i: "VGA-${toString i}") (lib.range 1 4));

    physicalCyclingSettings = lib.genAttrs physicalDisplayKeys (_:
      lib.mkForce {
        enabled = true;
        random = true;
        mode = "interval";
        interval = 300;
        folderPath = videoFolder;
        videoEnd = false; # loops seamlessly until 5-min timer
      });

    physicalFillModes = lib.genAttrs physicalDisplayKeys (_:
      lib.mkForce "PreserveAspectCrop");
  in {
    # 1. Symlink into ~/Pictures for easy user access
    home.file."Pictures/VideoWallpapers".source = videoFolder;

    # 2. Add ffmpeg to DMS PATH for lockscreen poster extraction & Matugen dynamic theming
    dmsExtraPackages = [ pkgs.ffmpeg-headless ];

    # 3. DMS session overrides
    programs.dank-material-shell.session = {
      # Global default: any screen not explicitly in monitorWallpapers (i.e. every physical screen) uses video
      wallpaperPath = lib.mkForce "${videoFolder}/${defaultVideo}";
      wallpaperCyclingFolderPath = lib.mkForce videoFolder;
      wallpaperCyclingEnabled = lib.mkForce true;
      wallpaperCyclingMode = lib.mkForce "interval";
      wallpaperCyclingInterval = lib.mkForce 300;
      wallpaperCyclingVideoEnd = lib.mkForce false;
      wallpaperFillMode = lib.mkForce "PreserveAspectCrop";

      # Enable cycling & fill mode for all physical displays (including laptop eDP-1, USB docks, projectors)
      monitorCyclingSettings = physicalCyclingSettings;
      monitorWallpaperFillModes = physicalFillModes;
    };
  };
}
