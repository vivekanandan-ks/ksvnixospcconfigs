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
    inputs.flake-file.flakeModules.auto-follow
    #inputs.flake-file.flakeModules.allfollow
    #inputs.flake-file.flakeModules.nix-auto-follow
  ];

  flake-file.inputs = {
    # nixpkgs.url is dynamically provided by flakepartsModules/multiverse-fp.nix via Multiverse tip
    # nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    #nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0"; # stable release
    # nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-file.url = lib.mkDefault "github:denful/flake-file";
    #nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:denful/import-tree";

    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
  };

  # Home Manager module to expose flake-edit in user PATH across all hosts
  flake.homeModules.common.flake-edit = {pkgs-unstable, ...}: {
    home.packages = [
      pkgs-unstable.flake-edit
    ];
  };
}
