{inputs, ...}: {
  flake-file.inputs = {
    dms-plugin-sands = {
      url = "github:lung595/Sands";
      flake = false;
    };
  };

  flake.homeModules.nonDroid.dms-plugin-sands = {pkgs, ...}: {
    programs.dank-material-shell.plugins.smartTimer = {
      src = inputs.dms-plugin-sands;
      enable = true;
    };

    dmsExtraPackages = [
      pkgs.pipewire
      pkgs.libnotify
      pkgs.glib
    ];
  };
}
