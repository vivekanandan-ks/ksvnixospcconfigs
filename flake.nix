# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  outputs =
    inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./flakepartsModules);

  nixConfig = {
    extra-substituters = [
      "https://vicinae.cachix.org"
      "https://cache.thalheim.io"
      "https://install.determinate.systems"
      "https://nyx-cache.chaotic.cx/"
      "https://chaotic-nyx.cachix.org"
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://hydra.nix-community.org"
      "https://devenv.cachix.org"
    ];
    extra-trusted-public-keys = [
      "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
      "cache.thalheim.io-1:R7msbosLEZKrxk/lKxf9BTjOOH7Ax3H0Qj0/6wiHOgc="
      "determinate.systems:2f5mBvfSEjPpdnsbvY+JnsrWvSAUVM+HxFpYr0WXB44="
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
      "nyx-cache.chaotic.cx:dJxTrgMC3V3cFfyIiBQDQorG6k1LsqurH/srpMSq7qk="
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];
  };

  inputs = {
    base16-schemes = {
      url = "github:tinted-theming/schemes";
      flake = false;
    };
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms-plugin-battery-plus = {
      url = "github:arcatva/dms-battery-plus";
      flake = false;
    };
    dms-plugin-hidden-bar = {
      url = "github:hthienloc/dms-hidden-bar";
      flake = false;
    };
    dms-plugin-material-player = {
      url = "github:notsopreety/materialPlayer";
      flake = false;
    };
    dms-plugin-modern-clock = {
      url = "github:beefsizzle/ModernClockDMS";
      flake = false;
    };
    dms-plugin-network-indicator = {
      url = "github:gemb0-0/Network-Indicator";
      flake = false;
    };
    dms-plugin-pure-lyrics = {
      url = "github:lildengzi/pureLyrics";
      flake = false;
    };
    dms-plugin-usb-manager = {
      url = "github:NordicsSys/dms-usb-manager";
      flake = false;
    };
    dms-plugin-wallpaper-carousel = {
      url = "github:motor-dev/wallpaperCarousel";
      flake = false;
    };
    dms-plugins-avengemedia = {
      url = "github:AvengeMedia/dms-plugins";
      flake = false;
    };
    dms-plugins-dadangdut33 = {
      url = "github:Dadangdut33/dms-plugins";
      flake = false;
    };
    dms-shell = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fast-nix-gc = {
      url = "github:Mic92/fast-nix-gc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-file.url = "github:vic/flake-file";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";
    ksv-personal-artifacts = {
      url = "github:vivekanandan-ks/ksv-personal-artifacts";
      flake = false;
    };
    mango = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    multiverse.url = "github:fzakaria/nixpkgs-multiverse";
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid";
      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
      };
    };
    nix4vscode = {
      url = "github:nix-community/nix4vscode";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-telemetry = {
      url = "github:mrVanDalo/nixos-telemetry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/9fbb54b33e91ee4ca368e35a78e0613c720600b3";
    nur = {
      url = "github:nix-community/NUR";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        nur.follows = "nur";
      };
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vicinae-extensions = {
      url = "github:vicinaehq/extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wrapper-modules = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xremap-flake = {
      url = "github:xremap/nix-flake";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };
}
