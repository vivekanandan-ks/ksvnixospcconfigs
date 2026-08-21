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

  flake.homeModules.nonDroid.dms = {lib, ...}: let
    wallpapers = builtins.attrNames (builtins.readDir self.personas.ksv.currentWallpaperSet);
    defaultWallpaper = builtins.head wallpapers;
  in {
    imports = [
      inputs.dms-shell.homeModules.default
    ];

    home.file.".face".source = self.personas.ksv.avatar;
    home.file.".face.icon".source = self.personas.ksv.avatar;
    home.file."Pictures/Wallpapers".source = self.personas.ksv.currentWallpaperSet;

    programs.dank-material-shell = {
      enable = true;
      systemd = {
        enable = true;
        target = "mango-session.target";
      };

      enableSystemMonitoring = true;
      enableDynamicTheming = false; # Stylix handles system and app theming
      enableVPN = true;
      enableCalendarEvents = true;

      session = builtins.fromJSON (builtins.readFile ./dms-session.json);
      # wallpaperPath override commented out to let DMS persist cycling state across logins:
      # session = lib.recursiveUpdate
      #   (builtins.fromJSON (builtins.readFile ./dms-session.json))
      #   {
      #     wallpaperPath = "${self.personas.ksv.currentWallpaperSet}/${defaultWallpaper}";
      #   };

      settings = lib.mapAttrs (name: value:
        if name == "barConfigs" then value else lib.mkForce value
      ) (builtins.fromJSON (builtins.readFile ./dms-settings.json));
    };
  };
}
