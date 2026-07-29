{
  inputs,
  lib,
  ...
}: {
  # generate the same output function we used at bootstrap
  flake-file.outputs = "inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./flakepartsModules)";

  imports = [
    # https://flake-file.denful.dev/guides/flake-modules/

    inputs.flake-file.flakeModules.default # necessary for bootstrap
    #inputs.flake-file.flakeModules.allfollow
    #inputs.flake-file.flakeModules.nix-auto-follow
  ];

  flake-file.inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    #nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0"; # stable release
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-file.url = lib.mkDefault "github:vic/flake-file";
    #nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
  };
}
