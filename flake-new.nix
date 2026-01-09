{
  description = "Description for the project";

  inputs = {
    #nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      #url = "github:nix-community/home-manager/release-25.05";
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # for vscode extensions
    nix4vscode = {
      url = "github:nix-community/nix4vscode";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (top@{ config, withSystem, moduleWithSystem, ... }: {
      imports = [
        # To import an internal flake module: ./other.nix
        # To import an external flake module:
        #   1. Add foo to inputs
        #   2. Add foo as a parameter to the outputs function
        #   3. Add here: foo.flakeModule

      ];
      systems = [ 
        "x86_64-linux" 
        "aarch64-linux" # Added for Nix-on-Droid 
        #"aarch64-darwin" 
        #"x86_64-darwin" 
      ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
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
      flake = let

        system = "x86_64-linux";

        commonConfigModules = [

          #inputs.nixpkgs.nixosModules.readOnlyPkgs

          ({ config, ... }: {

            # Use the configured pkgs from perSystem
            #_module.args.pkgs = withSystem system (
            #  { pkgs, ... }: # perSystem module arguments
            #  pkgs
            #);

            _module.args.pkgs-unstable = withSystem config.nixpkgs.hostPlatform.system (
              { pkgs-unstable, ... }: pkgs-unstable
            );

            _module.args = {
              #inherit inputs;
              inputs = inputs;
              username = "ksvnixospc";
              #isDroid = false;
              nix4vscode = inputs.nix4vscode;
              #system = system;
              inherit (config.nixpkgs.hostPlatform) system;
              
            };

          })

        ];

        isDroidModule = option: (
          [

            ({...}:{

              _module.args = {
                isDroid = option;
              };

            })

          ] 
          ++ (if !option then [
            # this section is for non nix-on-droid common modules
          #inputs.nixpkgs.nixosModules.readOnlyPkgs
        ] else [])
        );

       in 
       {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.

        nixosConfigurations.ksvnixospc = inputs.nixpkgs.lib.nixosSystem {

          inherit system; #system = "x86_64-linux";

          modules = [
            ./configuration.nix
            ./hosts/ksvnixospc/limine-ksvnixospc.nix
            ./hosts/ksvnixospc/hardware-configuration-ksvnixospc.nix
            inputs.home-manager.nixosModules.home-manager

          ] ++ (isDroidModule false) ++ commonConfigModules;


        };

        nixosConfigurations.deejunixospc = inputs.nixpkgs.lib.nixosSystem {

          inherit system; #system = "x86_64-linux";

          modules = [
            ./configuration.nix
            ./hosts/deejunixospc/limine-deejunixospc.nix
            ./hosts/deejunixospc/hardware-configuration-deejunixospc.nix
            inputs.home-manager.nixosModules.home-manager
            
          ] ++ (isDroidModule false) ++ commonConfigModules;


        };

        nixOnDroidConfigurations.default =  
          let
            system = "aarch64-linux";
          in 
          inputs.nix-on-droid.lib.nixOnDroidConfiguration {
          # Instantiate pkgs explicitly with the Droid overlay here
          pkgs = import inputs.nixpkgs {
            #system = "aarch64-linux";
            inherit system;
            config.allowUnfree = true;
            overlays = [ inputs.nix-on-droid.overlays.default ];
          };

          modules = [
            ./hosts/ksv-nix-on-droid/ksv-nix-on-droid.nix
            # list of extra modules for Nix-on-Droid system
            # { nix.registry.nixpkgs.flake = nixpkgs; }
            
            # Module injection for Nix-on-Droid
            ({ pkgs, ... }: {
              _module.args = {
                inherit inputs;
                
                # Manually define system since nix-on-droid doesn't strictly follow hostPlatform pattern
                inherit system;
                
                pkgs-unstable = withSystem system ({ pkgs-unstable, ... }: pkgs-unstable);
              };
            })
          ] 
          ++ (isDroidModule true); # Use the helper setting isDroid to true

          home-manager-path = inputs.home-manager.outPath;
        };


      };
    });
}
