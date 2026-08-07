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

  imports = [inputs.treefmt-nix.flakeModule];

  perSystem = _:
    lib.optionalAttrs (inputs ? treefmt-nix) {
      treefmt = {
        projectRootFile = "flake.nix";
        flakeFormatter = true;
        flakeCheck = true;

        programs = {
          # --- Nix Files ---
          alejandra.enable = true; # Fast Nix formatter

          deadnix = {
            enable = true;
            #no-lambda-arg = true; # Preserve unused function arguments
            #no-lambda-pattern-names = true; # Prevent breaking callPackage patterns
            #no-underscore = true; # Preserve _prefixed variables
          };

          statix.enable = true; # Nix anti-pattern linter

          # --- Shell Scripts ---
          shfmt = {
            enable = true;
            indent_size = 2;
          };

          # --- Markdown & JSON ---
          prettier = {
            enable = true;
            includes = [
              "*.md"
              "*.json"
            ];
          };

          # --- TOML Files ---
          taplo.enable = true;
        };

        # --- File Exclusions based on codebase scan ---
        settings.excludes = [
          # Auto-generated flake files
          "flake.nix"
          "flake.lock"

          # Media & Font assets
          "*.png"
          "*.jpg"
          "*.flf"

          # GLSL Shaders (Ghostty)
          "*.glsl"
          "**/ghostty-shaders/*"

          # Archival folders
          "unusedHomeModules/*"
          "unusedfpModules/*"
        ];
      };
    };
}
