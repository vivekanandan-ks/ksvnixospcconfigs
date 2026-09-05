{
  inputs,
  self,
  ...
}: {
  flake-file.inputs = {
    dms-shell = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.homeModules.nonDroid.dms = {
    config,
    lib,
    pkgs,
    ...
  }: let
    wallpapers = builtins.attrNames (builtins.readDir self.personas.ksv.currentWallpaperSet);
    defaultWallpaper = builtins.head wallpapers;

    wallpaperSet2Folder = "${self.personas.ksv.wallpapers}/drstone";
    wallpaperSet2DefaultWallpaper = builtins.head (builtins.attrNames (builtins.readDir wallpaperSet2Folder));

    # Pre-generate configurations for all possible headless outputs (HEADLESS-1 .. HEADLESS-50)
    headlessKeys = map (i: "HEADLESS-${toString i}") (lib.range 1 50);
    headlessMonitorWallpapers = lib.genAttrs headlessKeys (_: "${wallpaperSet2Folder}/${wallpaperSet2DefaultWallpaper}");
    headlessCyclingSettings = lib.genAttrs headlessKeys (_: {
      enabled = true;
      random = true;
      mode = "interval";
      interval = 300;
      folderPath = wallpaperSet2Folder;
    });
    headlessFillModes = lib.genAttrs headlessKeys (_: "Fill");
  in {
    imports = [
      inputs.dms-shell.homeModules.default
    ];

    home.file.".face".source = self.personas.ksv.avatar;
    home.file.".face.icon".source = self.personas.ksv.avatar;
    home.file."Pictures/Wallpapers".source = self.personas.ksv.currentWallpaperSet;

    programs.dank-material-shell = {
      enable = true;
      package = pkgs.symlinkJoin {
        name = "dms-shell-wrapped";
        paths = [inputs.dms-shell.packages.${pkgs.stdenv.hostPlatform.system}.default];
        nativeBuildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/dms \
            --prefix PATH : ${lib.makeBinPath config.dmsExtraPackages}
        '';
        meta.mainProgram = "dms";
      };

      systemd = {
        enable = true;
        target = "mango-session.target";
      };

      enableSystemMonitoring = true;
      enableDynamicTheming = true;
      enableVPN = false;
      enableCalendarEvents = true;

      session =
        lib.recursiveUpdate
        (builtins.fromJSON (builtins.readFile ./dms-session.json))
        {
          wallpaperPath = "${self.personas.ksv.currentWallpaperSet}/${defaultWallpaper}";
          monitorWallpapers = headlessMonitorWallpapers;
          monitorWallpaperFillModes = headlessFillModes;
          monitorCyclingSettings =
            headlessCyclingSettings
            // {
              "eDP-1" = {
                enabled = true;
                random = true;
                mode = "interval";
                interval = 300;
                folderPath = self.personas.ksv.currentWallpaperSet;
              };
            };
        };

      settings = lib.mapAttrs (
        name: value:
          if name == "barConfigs"
          then value
          else lib.mkForce value
      ) (builtins.fromJSON (builtins.readFile ./dms-settings.json));
    };
  };
}
