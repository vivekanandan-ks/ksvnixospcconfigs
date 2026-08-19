{inputs, ...}: {
  flake-file.inputs = {
    fast-nix-gc = {
      url = "github:Mic92/fast-nix-gc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.nixosModules.fast-nix-gc = {
    imports = [
      inputs.fast-nix-gc.nixosModules.default
    ];

    nix.settings = {
      extra-substituters = ["https://cache.thalheim.io"];
      extra-trusted-public-keys = ["cache.thalheim.io-1:R7msbosLEZKrxk/lKxf9BTjOOH7Ax3H0Qj0/6wiHOgc="];
    };

    # High-performance multi-threaded Nix GC and store deduplication
    services.fast-nix-gc = {
      enable = true;
      automatic = true;
      dates = "weekly";
      deleteOlderThan = "30d";
    };

    services.fast-nix-optimise = {
      enable = true;
      automatic = true;
      dates = "weekly";
    };
  };
}
