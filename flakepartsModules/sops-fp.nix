{
  inputs,
  lib,
  ...
}: {
  # 1. Register sops-nix in flake.nix
  flake-file.inputs = {
    sops-nix.url = "github:Mic92/sops-nix";
  };

  # 2. Configure sops for NixOS
  flake.nixosModules.sops = {
    config,
    pkgs,
    username,
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

      # System-level secret available to user without needing ~/.config/sops/age/keys.txt
      secrets.github_token = {
        owner = username;
        group = "users";
        mode = "0400";
      };
    };
  };

  # 3. Home Manager Configuration (Manages your user secrets!)
  # Commented out to eliminate the imperative ~/.config/sops/age/keys.txt anti-pattern.
  # All secrets are now managed declaratively at the NixOS system level using host SSH keys.
  /*
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
  */
}
