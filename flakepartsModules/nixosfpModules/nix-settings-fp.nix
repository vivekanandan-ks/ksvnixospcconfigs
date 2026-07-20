{...}: {
  flake.nixosModules.nix-settings = {
    nix.settings = {
      /*
        substituters = [
        "https://hyprland.cachix.org"
      ];
      trusted-substituters = [
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        ];
      */
      trusted-users = ["root" "@wheel"];

      extra-substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://cache.garnix.io"
        "https://chaotic-nyx.cachix.org"
        "https://hyprland.cachix.org"
        "https://devenv.cachix.org"
        "https://hydra.nix-community.org"
      ];

      extra-trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];

      # download buffer size; default size is 16mb (16*1024*1024)
      #download-buffer-size = 6710886400;

      auto-optimise-store = true; # if set to false(default) then run " nix-store --optimise " periodically to get rid of duplicate files.

      #Enable flakes
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

    # Nix GC
    /*
    nix.gc = {
      automatic = true;
      #persistent = false;
      dates = "daily";
      options = "--delete-older-than 7d";
      #randomizedDelaySec = "30min";
    };
    */
  };
}
