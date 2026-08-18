{inputs, ...}: let
  # 1. Shared Nix settings (applied to both /etc/nix/nix.conf and ~/.config/nix/nix.conf)
  commonSettings = {
    # Enable modern CLI commands and flakes
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Auto-optimise store on new builds
    auto-optimise-store = true;

    # Allow import-from-derivation
    allow-import-from-derivation = true;

    # Binary cache substituters
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://chaotic-nyx.cachix.org"
      "https://hyprland.cachix.org"
      "https://devenv.cachix.org"
      "https://hydra.nix-community.org"
      "https://install.determinate.systems"
      #"https://cache.garnix.io"

      /*
        # status: https://mirrors.nju.edu.cn/
      "https://mirrors.nju.edu.cn/nix-channels/store"

      # status: https://mirror.sjtu.edu.cn/
      "https://mirror.sjtu.edu.cn/nix-channels/store"

      # status: https://mirrors.tuna.tsinghua.edu.cn/
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      */
    ];

    # Trusted public keys for signature verification
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "determinate.systems:2f5mBvfSEjPpdnsbvY+JnsrWvSAUVM+HxFpYr0WXB44="
      #"cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];

    # download buffer size; default size is 16mb (16*1024*1024)
    #download-buffer-size = 6710886400;
  };

  # 2. Shared flake registries (accessible via `nix run nixpkgs#...` and `nix shell nixpkgs#...`)
  commonRegistry = {
    nixpkgs.flake = inputs.nixpkgs;
  };
in {
  # ─── NIXOS MODULE ──────────────────────────────────────────────────────────
  flake.nixosModules.nix-settings = _: {
    nix = {
      settings =
        commonSettings
        // {
          trusted-users = ["root" "@wheel"];
        };
      registry = commonRegistry;

      # Nix GC
      /*
      gc = {
        automatic = true;
        #persistent = false;
        dates = "daily";
        options = "--delete-older-than 7d";
        #randomizedDelaySec = "30min";
      };
      */
    };
  };

  # ─── HOME MANAGER MODULE ───────────────────────────────────────────────────
  flake.homeModules.common.nix-settings = {
    pkgs,
    lib,
    ...
  }: {
    nix = {
      package = lib.mkDefault pkgs.nix;
      nixPath = ["nixpkgs=${pkgs.path}"];
      settings = commonSettings;
      registry = commonRegistry;
    };
  };
}
