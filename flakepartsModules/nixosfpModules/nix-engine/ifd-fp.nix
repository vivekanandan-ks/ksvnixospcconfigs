_: {
  # 1. Top-level Flake nixConfig setting (via flake-file)
  /*
    flake-file.nixConfig = {
    allow-import-from-derivation = false;
  };
  */

  # 2. NixOS System-level setting
  flake.nixosModules.ifd = {
    nix.settings = {
      allow-import-from-derivation = true;
    };
    # nixpkgs.config.allowIfd = true;
  };

  # 3. Home Manager-level setting
  flake.homeModules.common.ifd = {
    nix.settings = {
      allow-import-from-derivation = true;
    };
    # nixpkgs.config.allowIfd = true;
  };
}
