{inputs, ...}: {
  flake-file.inputs = {
    dms-plugin-orbit-bluetooth = {
      url = "github:lung595/orbitBluetooth";
      flake = false;
    };
  };

  flake.homeModules.nonDroid.dms-plugin-orbit-bluetooth = {pkgs, ...}: {
    programs.dank-material-shell.plugins.orbitBluetooth = {
      src = inputs.dms-plugin-orbit-bluetooth;
      enable = true;
    };

    dmsExtraPackages = [
      pkgs.python3
      pkgs.pipewire
      pkgs.cava
      pkgs.pulseaudio
    ];

    dms.extraRightWidgets = [
      "orbitBluetooth"
    ];

    dms.extraControlCenterWidgets = [
      {
        col = 0;
        enabled = true;
        h = 1;
        id = "plugin_orbitBluetooth";
        row = 6;
        w = 4;
      }
    ];
  };
}
