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
      enableVPN = true;
      enableCalendarEvents = true;

      session =
        lib.recursiveUpdate
        (builtins.fromJSON (builtins.readFile ./dms-session.json))
        {
          wallpaperPath = "${self.personas.ksv.currentWallpaperSet}/${defaultWallpaper}";
          monitorWallpapers = {
            "HEADLESS-1" = "${wallpaperSet2Folder}/${wallpaperSet2DefaultWallpaper}";
          };
          monitorCyclingSettings = {
            "eDP-1" = {
              enabled = true;
              random = true;
              mode = "interval";
              interval = 300;
              folderPath = self.personas.ksv.currentWallpaperSet;
            };
            "HEADLESS-1" = {
              enabled = true;
              random = true;
              mode = "interval";
              interval = 300;
              folderPath = wallpaperSet2Folder;
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
