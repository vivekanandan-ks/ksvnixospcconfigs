{
  inputs,
  lib,
  ...
}: {
  flake-file.inputs = {
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  imports = lib.optionals (inputs ? treefmt-nix) [
    inputs.treefmt-nix.flakeModule
  ];

  perSystem = lib.optionalAttrs (inputs ? treefmt-nix) {
    treefmt = {
      projectRootFile = "flake.nix";
      flakeFormatter = true;
      flakeCheck = true;

      programs = {
        alejandra.enable = true; # Fast Nix formatter

        deadnix = {
          enable = true;
          #no-lambda-arg = true; # Preserve unused function arguments
          #no-lambda-pattern-names = true; # Prevent breaking callPackage patterns
          #no-underscore = true; # Preserve _prefixed variables
        };

        statix.enable = true; # Nix anti-pattern linter

        nixf-diagnose = {
          enable = true;
          autoFix = false; # Diagnostic checks without modifying files
          ignore = [
            #"sema-extra-with"
            "sema-primop-removed-prefix"
          ];
        };

        # --- Shell Scripts ---
        shfmt = {
          enable = true;
          indent_size = 2;
        };

        # --- Markdown & JSON ---
        oxfmt = {
          enable = true;
          includes = [
            "*.md"
            "*.json"
          ];
        };

        # --- TOML Files ---
        taplo.enable = true;

        # --- Image Optimization ---
        oxipng = {
          enable = true;
          opt = "2";
          strip = "safe";
          alpha = true;
        };
      };

      settings = {
        # Log paths that did not match any formatter
        on-unmatched = "warn";

        # --- File Exclusions based on codebase scan ---
        excludes = [
          # Auto-generated flake files
          "flake.nix"
          "flake.lock"

          # Media, Font & Config assets without formatters
          "*.jpg"
          "*.jpeg"
          "*.flf"
          "*.txt"
          "*.conf"

          # GLSL Shaders (Ghostty)
          "*.glsl"
          "**/ghostty-shaders/*"

          # Archival folders
          "unusedHomeModules/*"
          "unusedfpModules/*"
        ];
      };
    };
  };
}
