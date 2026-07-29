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
    inputs.flake-file.flakeModules.allfollow
  ];

  flake-file.inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    #nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0"; # stable release
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-file.url = lib.mkDefault "github:vic/flake-file";
    #nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    /*
      plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    */

    /*
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    */

    /*
    kwin-effects-forceblur = {
    url = "github:taj-ny/kwin-effects-forceblur";
    inputs.nixpkgs.follows = "nixpkgs";
    };
    */
  };
}
