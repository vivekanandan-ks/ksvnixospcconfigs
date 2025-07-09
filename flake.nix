{
  description = "A very basic flake";
  
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    /*kwin-effects-forceblur = {
      url = "github:taj-ny/kwin-effects-forceblur";
      inputs.nixpkgs.follows = "nixpkgs";
    };*/
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... } @ inputs : 
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

  in {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs pkgs pkgs-unstable;
            #inherit pkgs;
          };
          modules = [
            ./configuration.nix
          ];

        };
      
      };
}