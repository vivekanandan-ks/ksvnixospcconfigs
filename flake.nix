{
  description = "Description for the project";

  inputs = {
    #nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    #nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0"; # stable release
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      #url = "github:nix-community/home-manager/release-25.05";
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    # for vscode extensions
    nix4vscode = {
      url = "github:nix-community/nix4vscode";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    xremap-flake.url = "github:xremap/nix-flake";

    # nvf - modern, reproducible, portable, declarative neovim framework
    #obsidian-nvim.url = "github:epwalsh/obsidian.nvim";
    nvf = {
      url = "github:NotAShelf/nvf";
      # You can override the input nixpkgs to follow your system's
      # instance of nixpkgs. This is safe to do as nvf does not depend
      # on a binary cache.
      inputs.nixpkgs.follows = "nixpkgs";
      # Optionally, you can also override individual plugins
      # for example:
      #inputs.obsidian-nvim.follows = "obsidian-nvim"; # <- this will use the obsidian-nvim from your inputs
    };

    # https://github.com/gmodena/nix-flatpak
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        # IMPORTANT: we're using "libgbm" and is only available in unstable so ensure
        # to have it up-to-date or simply don't specify the nixpkgs input
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #noctalia = {
    #  url = "github:noctalia-dev/noctalia-shell";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    vicinae-extensions = {
      url = "github:vicinaehq/extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # hyprland
    #hyprland.url = "github:hyprwm/Hyprland";
    /*
    hyprland = {
      #type = "git";
      url = "github:hyprwm/Hyprland";
      #submodules = true;
      #inputs.nixpkgs.follows = "nixpkgs"; # commenting means we use latest hyprland directly
    };

    # hyprland official plugins
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    # a hyprland plugin refer: https://github.com/KZDKM/Hyprspace
    Hyprspace = {
      url = "github:KZDKM/Hyprspace";
      # Hyprspace uses latest Hyprland. We declare this to keep them in sync.
      inputs.hyprland.follows = "hyprland";
    };

    # unofficial hyprexpo alternative
    hyprtasking = {
      url = "github:raybbian/hyprtasking";
      inputs.hyprland.follows = "hyprland";
    };

    hypr-dynamic-cursors = {
      url = "github:VirtCode/hypr-dynamic-cursors";
      inputs.hyprland.follows = "hyprland"; # to make sure that the plugin is built for the correct version of hyprland
    };
    */

    /*
    niri = {
      url = "github:sodiboo/niri-flake";
    };
    */

    /*
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    */

    kwin-effects-forceblur = {
      url = "github:taj-ny/kwin-effects-forceblur";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid";
      #url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} (
      top @ {
        config,
        withSystem,
        moduleWithSystem,
        lib,
        ...
      }: {
        imports = [
          {
            options.flake.homeModules = lib.mkOption {
              type = lib.types.lazyAttrsOf lib.types.unspecified;
              default = {};
            };
            options.flake.hardwareModules = lib.mkOption {
              type = lib.types.lazyAttrsOf lib.types.unspecified;
              default = {};
            };
          }
          (inputs.import-tree ./flakepartsModules)
          # To import an internal flake module: ./other.nix
          # To import an external flake module:
          #   1. Add foo to inputs
          #   2. Add foo as a parameter to the outputs function
          #   3. Add here: foo.flakeModule
        ];
        systems = [
          "x86_64-linux" # flake.homeModules.netbird-ui
          "aarch64-linux" # Added for Nix-on-Droid
          #"aarch64-darwin"
          #"x86_64-darwin"
        ];
        perSystem = {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }: {
          # Per-system attributes can be defined here. The self' and inputs'
          # module parameters provide easy access to attributes of the same
          # system.

          # Equivalent to  inputs'.nixpkgs.legacyPackages.hello;
          #packages.default = pkgs.hello;

          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
            nvidia.acceptLicense = true;
            #overlays = [ inputs.foo.overlays.default ];
          };

          _module.args.pkgs-unstable = import inputs.nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
            nvidia.acceptLicense = true;
            #overlays = [ inputs.foo.overlays.default ];
          };
        };
        flake = {
          ksvnixospc = top.self.nixosConfigurations.ksvnixospc;
          deejunixospc = top.self.nixosConfigurations.deejunixospc;
        };
      }
    );
}
