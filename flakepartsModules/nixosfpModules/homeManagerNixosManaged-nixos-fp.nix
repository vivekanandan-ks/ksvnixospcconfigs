{config, ...}: {
  flake.nixosModules.homeManagerNixosManaged = {
    globalModuleArgs,
    inputs,
    isDroid ? false,
    username,
    self,
    ...
  }: {
    home-manager = {
      extraSpecialArgs =
        globalModuleArgs
        // {
          inherit
            globalModuleArgs
            inputs
            isDroid
            username
            self
            ;
        };
      #users.ksvnixospc = import ./home.nix;
      #users.ksvnixospc = {
      users."${username}" = {
        imports = [
          config.flake.homeModules.home
        ];
      };
      backupFileExtension = "backup";
      backupCommand = "rm -f $1.backup && mv $1 $1.backup";
      #useGlobalPkgs = false;
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = [
        #inputs.plasma-manager.homeModules.plasma-manager
        #inputs.xremap-flake.homeManagerModules.default # added in home.nix
        #inputs.sops-nix.homeManagerModules.sops
      ];
    };
  };
}
