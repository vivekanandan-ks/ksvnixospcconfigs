{
  description = "A very basic flake";

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

  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nix4vscode,
      ...
    }@inputs:
    let
    # find system using the below command:
    # nix eval --raw --impure --expr "builtins.currentSystem"
      system = "x86_64-linux";
      #pkgs = nixpkgs.legacyPackages."${system}";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        nvidia.acceptLicense = true;
      };

      #pkgs-unstable = nixpkgs-unstable.legacyPackages."${system}";
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
        nvidia.acceptLicense = true;
      };

    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit
            inputs
            #pkgs # https://discourse.nixos.org/t/error-persists-even-after-allowing-unfree-and-nvidia-acceptlicense-to-true/72096/2?u=ksvivek
            system
            pkgs-unstable
            nix4vscode
            ;
        };
        modules = [
          ./configuration.nix
        ];

      };

    };
}
