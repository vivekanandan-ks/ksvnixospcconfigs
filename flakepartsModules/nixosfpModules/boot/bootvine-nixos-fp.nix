{inputs, ...}: {
  # 1. Flake input declaration for flake-file
  flake-file.inputs = {
    bootvine = {
      url = "git+https://codeberg.org/wvhulle/bootvine";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # 2. Binary cache configuration (avoids building Rust from source)
  flake-file.nixConfig = {
    extra-substituters = [
      "https://wvhulle.cachix.org"
    ];
    extra-trusted-public-keys = [
      "wvhulle.cachix.org-1:heXx8DZMiRsKUx6l1TxNoF+Nmtmz66QEdsonQzc1ir0="
    ];
  };

  # 3. Flake NixOS module (automatically imported across all NixOS hosts)
  flake.nixosModules.bootvine = {lib, ...}: {
    imports = [
      inputs.bootvine.nixosModules.default
    ];

    # Enable service with default settings
    services.bootvine = {
      enable = lib.mkDefault true;
      # settings = {
      #   timing.keep-final-frame-for = "500ms";
      # };
    };

    # Suppresses non-error kernel console messages so the bootvine tree stays clean
    boot.consoleLogLevel = lib.mkDefault 3;
  };
}
