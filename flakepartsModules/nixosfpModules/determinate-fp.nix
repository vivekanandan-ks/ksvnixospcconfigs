{inputs, ...}: {
  flake-file.inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
  };

  flake.nixosModules.determinate = {...}: {
    imports = [
      inputs.determinate.nixosModules.default # sets detsys nix as the default nix
    ];
  };
}
