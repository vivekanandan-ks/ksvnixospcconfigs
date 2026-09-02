{
  config,
  self,
  ...
}: {
  flake.nixOnDroidModules.ksv-nix-on-droid = {globalModuleArgs, ...}: let
    inherit (globalModuleArgs) pkgs-global pkgs-unstable pkgs-stable;
  in {
    android-integration.termux-setup-storage.enable = true;
    android-integration.am.enable = true;
    android-integration.termux-open.enable = true;
    android-integration.termux-open-url.enable = true;
    android-integration.termux-reload-settings.enable = true;
    android-integration.termux-wake-lock.enable = true;
    android-integration.termux-wake-unlock.enable = true;
    android-integration.xdg-open.enable = true;

    # default shell for nix-on-droid
    user.shell = "${pkgs-unstable.nushell}/bin/nu";

    # Simply install just the packages
    environment.packages = with pkgs-stable; [
      vim
      openssh
      iputils
    ];

    # Backup etc files instead of failing to activate generation if a file already exists in /etc
    environment.etcBackupExtension = ".bak";

    # Read the changelog before changing this value
    system.stateVersion = "24.05";

    # Set up nix for flakes
    nix.package = pkgs-global.nix;
    nix.extraOptions = ''
      experimental-features = nix-command flakes
    '';

    # Set your time zone
    time.timeZone = "Asia/Kolkata";

    # terminal font
    terminal.font = let
      fontPkg = self.personas.ksv.font.monospace.package pkgs-unstable;
    in
      pkgs-unstable.runCommand "termux-font.ttf" {} ''
        cp $(find ${fontPkg} -name "*Mono-Regular.ttf" -o -name "*Regular.ttf" | head -n1) $out
      '';

    # Configure home-manager
    home-manager = {
      extraSpecialArgs =
        globalModuleArgs
        // {
          inherit globalModuleArgs;
          username = "nix-on-droid";
        };
      config = {
        imports = builtins.attrValues (config.flake.homeModules.common or {});
      };
      backupFileExtension = "bak";
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = [];
    };
  };
}
