{inputs, ...}: {
  flake-file.inputs = {
    dms-plugins-conava = {
      url = "github:Conava/dux-plugins";
      flake = false;
    };
  };

  flake.homeModules.nonDroid.dms-plugin-cast = _: {
    programs.dank-material-shell.plugins.cast = {
      src = "${inputs.dms-plugins-conava}/Cast";
      enable = true;
    };
  };
}
