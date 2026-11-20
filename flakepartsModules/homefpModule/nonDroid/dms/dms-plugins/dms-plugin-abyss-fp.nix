{inputs, ...}: {
  flake-file.inputs = {
    dms-plugin-abyss = {
      url = "github:lung595/Abyss";
      flake = false;
    };
  };

  flake.homeModules.nonDroid.dms-plugin-abyss = {pkgs, ...}: {
    programs.dank-material-shell.plugins.abyss = {
      src = inputs.dms-plugin-abyss;
      enable = true;
    };

    dmsExtraPackages = [
      pkgs.netbird
      pkgs.openssh
      pkgs.zenity
      pkgs.wl-clipboard
      pkgs.iproute2
    ];

    dms.extraRightWidgets = [
      "abyss"
    ];

    dms.extraControlCenterWidgets = [
      {
        col = 4;
        enabled = true;
        h = 1;
        id = "plugin_abyss";
        row = 6;
        w = 4;
      }
    ];
  };
}
