{inputs, ...}: {
  # Define the multiverse input for flake-file
  flake-file.inputs = {
    multiverse.url = "github:fzakaria/nixpkgs-multiverse";

    # Dynamic Nixpkgs Flake URL derived from Multiverse tip:
    # Keeps `inputs.nixpkgs` and all downstream `follows = "nixpkgs"` in sync with Multiverse,
    # preventing duplicate nixpkgs trees, saving disk/eval time, and ensuring 100% store deduplication.
    nixpkgs.url = let
      mv = builtins.head (builtins.attrValues inputs.multiverse.multiverse);
    in "github:nixos/nixpkgs/${(mv.flakeAt "tip").rev}";
  };

  # Auto-registered Home Manager module for the `mv` CLI registry
  flake.homeModules.common.multiverse-registry = _: {
    nix.registry.mv.flake = inputs.multiverse;
  };

  # Configure per-system module arguments
  perSystem = {system, ...}: let
    mv = inputs.multiverse.lib.mkMultiverse {
      inherit system;
      config = {
        allowUnfree = true;
        nvidia.acceptLicense = true;
      };
      fastFallback = "eval"; # Seamless fallback for unfree packages
    };
    globalModuleArgs = {
      inherit mv;
      # 0. Global System Package Set (feeds nixpkgs.pkgs)
      pkgs-global = mv.tip;
      # 1. Unstable Native: For complex NixOS/HM modules, login shells, and services
      pkgs-unstable = mv.tip;
      # 2. Stable Channel: Access official stable packages on-demand with zero flake inputs
      pkgs-stable = mv.at "26.05";
      # 3. Flake Tip: Synthesized flake object (.lib.nixosSystem, .legacyPackages, etc.)
      # flake-tip = mv.flakeAt "tip";
    };
  in {
    _module.args =
      globalModuleArgs
      // {
        pkgs = mv.tip;
        inherit globalModuleArgs;
      };
  };
}
