{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # for vscode extensions
    nix4vscode = {
      url = "github:nix-community/nix4vscode";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    /*sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };*/
    /*
      kwin-effects-forceblur = {
        url = "github:taj-ny/kwin-effects-forceblur";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    */
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
      system = "x86_64-linux";
      #pkgs = nixpkgs.legacyPackages."${system}";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      #pkgs-unstable = nixpkgs-unstable.legacyPackages."${system}";
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs pkgs pkgs-unstable nix4vscode system;
        };
        modules = [
          ./configuration.nix
        ];

      };

    };
}
