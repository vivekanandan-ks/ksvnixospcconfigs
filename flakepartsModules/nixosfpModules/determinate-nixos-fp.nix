{inputs, ...}: {
  flake-file.inputs = {
    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.nixosModules.determinate = {...}: {
    imports = [
      inputs.determinate.nixosModules.default # sets detsys nix as the default nix
    ];

    nix.settings = {
      extra-substituters = [
        "https://install.determinate.systems"
      ];

      extra-trusted-public-keys = [
        "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
      ];
    };
  };
}
