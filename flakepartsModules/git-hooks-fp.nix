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
          # --- Secret & Credential Protection ---
          ripsecrets.enable = true;
          detect-private-keys.enable = true;
          detect-aws-credentials.enable = true;
          trufflehog.enable = true;
          pre-commit-hook-ensure-sops.enable = true;

          # --- Nix & Flake Health ---
          flake-checker.enable = true;

          # --- Git Hygiene & File Sanity ---
          check-merge-conflicts.enable = true;
          check-symlinks.enable = true;
          forbid-new-submodules.enable = true;
          check-added-large-files.enable = true;
          check-case-conflicts.enable = true;
        };
      };
    };
  };
}
