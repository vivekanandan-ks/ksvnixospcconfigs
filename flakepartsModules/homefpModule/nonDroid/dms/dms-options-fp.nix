_: {
  flake.homeModules.nonDroid.dms-options = {lib, ...}: {
    options.dmsExtraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Runtime dependencies added to the DankMaterialShell PATH wrapper.";
    };
  };
}
