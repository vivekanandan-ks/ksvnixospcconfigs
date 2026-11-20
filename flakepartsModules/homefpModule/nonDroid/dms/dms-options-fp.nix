_: {
  flake.homeModules.nonDroid.dms-options = {lib, ...}: {
    options.dmsExtraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Runtime dependencies added to the DankMaterialShell PATH wrapper (legacy alias).";
    };

    options.dms = {
      extraPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
        description = "Runtime dependencies added to the DankMaterialShell PATH wrapper.";
      };

      extraLeftWidgets = lib.mkOption {
        type = lib.types.listOf (lib.types.either lib.types.str lib.types.attrs);
        default = [];
        description = "Extra widgets appended on the right of leftWidgets.";
      };

      extraCenterWidgets = lib.mkOption {
        type = lib.types.listOf (lib.types.either lib.types.str lib.types.attrs);
        default = [];
        description = "Extra widgets appended on the right of centerWidgets.";
      };

      extraRightWidgets = lib.mkOption {
        type = lib.types.listOf (lib.types.either lib.types.str lib.types.attrs);
        default = [];
        description = "Extra widgets prepended on the left of rightWidgets.";
      };

      extraControlCenterWidgets = lib.mkOption {
        type = lib.types.listOf lib.types.attrs;
        default = [];
        description = "Extra tiles appended to Control Center.";
      };
    };
  };
}
