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

  flake.homeModules.nonDroid.dms = {lib, ...}: {
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

      settings = lib.mapAttrs (_: lib.mkForce) (builtins.fromJSON (builtins.readFile ./dms-settings.json));
    };
  };
}
