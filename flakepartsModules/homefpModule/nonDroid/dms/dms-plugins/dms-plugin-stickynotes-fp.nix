{inputs, ...}: {
  flake-file.inputs = {
    dms-plugin-stickynotes = {
      url = "github:iSparsh/dms-stickynotes";
      flake = false;
    };
  };

  flake.homeModules.nonDroid.dms-plugin-stickynotes = _: {
    programs.dank-material-shell.plugins.stickyNotes = {
      src = inputs.dms-plugin-stickynotes;
      enable = true;
    };
  };
}
