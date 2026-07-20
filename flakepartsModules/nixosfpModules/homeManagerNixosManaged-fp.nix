{config, ...}: {
  flake.nixosModules.homeManagerNixosManaged = {
    inputs,
    pkgs,
    pkgs-unstable,
    nix4vscode,
    system,
    isDroid ? false,
    username,
    self,
    ...
  }: {
    home-manager = {
      extraSpecialArgs = {
        inherit
          inputs
          pkgs
          pkgs-unstable
          nix4vscode
          system
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
      # backupFileExtension = lib.mkForce null;
      # backupCommand = "sh -c 'mv $0 $0.backup-$(date +%s)'";
      useGlobalPkgs = false;
      useUserPackages = true;
      sharedModules = [
        #inputs.plasma-manager.homeModules.plasma-manager
        #inputs.xremap-flake.homeManagerModules.default # added in home.nix
        #inputs.sops-nix.homeManagerModules.sops
      ];
    };
  };
}
