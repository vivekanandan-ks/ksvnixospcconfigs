{inputs, ...}: {
  flake-file.inputs = {
    dms-plugins-sitolam = {
      url = "github:sitolam/dms-plugins";
      flake = false;
    };
  };

  flake.homeModules.nonDroid.dms-plugin-bardropdown = _: {
    programs.dank-material-shell.plugins.barDropdown = {
      src = "${inputs.dms-plugins-sitolam}/plugins/bardropdown";
      enable = true;
      settings = {
        targets = [
          "scratchpadHelper"
          "ambientSound"
          "mediaControlPlus"
          "storageMonitor"
          "dankCleaner"
          "dnsSwitcher"
          "caffeineRedesigned"
          "screenRecorderLH"
          "virtualKeyboard"
        ];
      };
    };
  };
}
