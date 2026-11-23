{inputs, ...}: {
  # 1. Flake input declaration (harvested by flake-file to update flake.nix)
  flake-file.inputs = {
    iets = {
      url = "github:numtide/iets";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # 2. Binary cache substituter & key (harvested by flake-file)
  flake-file.nixConfig = {
    extra-substituters = [
      "https://cache.numtide.com"
    ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  # 3. System-wide NixOS module (automatically imported by common-hosts-fp.nix)
  flake.nixosModules.iets = {pkgs, ...}: {
    # Installs `iets` CLI system-wide alongside Determinate Nix
    environment.systemPackages = [
      inputs.iets.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
