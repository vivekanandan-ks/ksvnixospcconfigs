{
  inputs,
  lib,
  ...
}: {
  flake-file.inputs.git-hooks-nix = {
    url = "github:cachix/git-hooks.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  imports = lib.optionals (inputs ? git-hooks-nix) [
    inputs.git-hooks-nix.flakeModule
  ];

  perSystem = lib.optionalAttrs (inputs ? git-hooks-nix) {
    pre-commit = {
      check.enable = true; # Adds security checks to `nix flake check`

      settings = {
        default_stages = ["manual"];

        hooks = {
          # Prevent committing private keys, tokens, and secret passwords
          ripsecrets.enable = true;

          # Prevent committing files with git merge conflict markers (<<<<<<< HEAD)
          check-merge-conflicts.enable = true;

          # Detect broken relative symlinks
          check-symlinks.enable = true;

          # Prevent adding git submodules by accident
          forbid-new-submodules.enable = true;
        };
      };
    };
  };
}
