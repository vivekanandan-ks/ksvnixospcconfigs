{
  inputs,
  lib,
  ...
}: {
  # Declare disko input using flake-file
  flake-file.inputs.disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # Import disko flake-parts module
  imports = lib.optionals (inputs ? disko) [
    inputs.disko.flakeModules.default
  ];
}
