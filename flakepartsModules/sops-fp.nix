{
  inputs,
  lib,
  ...
}: {
  # 1. Register sops-nix in flake.nix
  flake-file.inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # 2. Configure sops for NixOS
  flake.nixosModules.sops = {
    config,
    pkgs,
    ...
  }: {
    imports = lib.optionals (inputs ? sops-nix) [
      inputs.sops-nix.nixosModules.sops
    ];

    # Make the 'sops' CLI tool always available in your terminal
    environment.systemPackages = [ pkgs.sops ];

    sops = {
      defaultSopsFile = ../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";

      # NOTE: age.sshKeyPaths is omitted (Option 1).
      # It dynamically auto-detects from config.services.openssh.hostKeys.
    };
  };

  # 3. Home Manager Configuration (Manages your user secrets!)
  flake.homeModules.common.sops = {
    config,
    ...
  }: {
    imports = lib.optionals (inputs ? sops-nix) [
      inputs.sops-nix.homeManagerModules.sops
    ];

    sops = {
      defaultSopsFile = ../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";

      # Home Manager uses your user's Age key
      age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

      # Clean, simple user-level secret declaration:
      secrets.github_token = {};
    };
  };
}
