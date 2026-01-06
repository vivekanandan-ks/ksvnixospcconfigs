{ config, lib, pkgs, inputs, pkgs-unstable, isDroid, ... }:

{

    android-integration.termux-setup-storage.enable = true;
    android-integration.am.enable = true;
    android-integration.termux-open.enable = true;
    android-integration.termux-open-url.enable = true;
    android-integration.termux-reload-settings.enable = true;
    android-integration.termux-wake-lock.enable = true;
    android-integration.termux-wake-unlock.enable = true;
    android-integration.xdg-open.enable = true;



  # default shell for nix-on-droid
  user.shell = "${pkgs.nushell}/bin/nu";

  # Simply install just the packages
  environment.packages = with pkgs; [
    # User-facing stuff that you really really want to have
    vim # or some other editor, e.g. nano or neovim

    openssh
    iputils

    # Some common stuff that people expect to have
    #procps
    #killall
    #diffutils
    #findutils
    #utillinux
    #tzdata
    #hostname
    #man
    #gnugrep
    #gnupg
    #gnused
    #gnutar
    #bzip2
    #gzip
    #xz
    #zip
    #unzip
  ];

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "24.05";

  # Set up nix for flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Set your time zone
  time.timeZone = "Asia/Kolkata";

  # terminal font
  #terminal.font = "${pkgs.nerd-fonts.fira-code}/share/fonts/truetype/NerdFonts/FiraCode/FiraCodeNerdFont-Regular.ttf";
  terminal.font = let
    jetbrains = pkgs.nerd-fonts.jetbrains-mono; #pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
    fontPath =
      "share/fonts/truetype/NerdFonts/JetBrainsMono/JetBrainsMonoNerdFontMono-Regular.ttf";
  in "${jetbrains}/${fontPath}";


  # Configure home-manager
  home-manager = {
    config = ./../../home.nix ;
    backupFileExtension = "bak";
    #backupFileExtension = lib.mkForce null;
    #backupCommand = "sh -c 'mv $0 $0.backup-$(date +%s)'";
    
    # Reason: Resolves "You have set either `nixpkgs.config` or `nixpkgs.overlays` while using `home-manager.useGlobalPkgs`" warning.
    # Pros: Allows modules (like Stylix) to configure nixpkgs options without conflict.
    # Cons: Home Manager instantiates its own pkgs set, which may increase evaluation time and duplicate package instances.
    useGlobalPkgs = false;
    useUserPackages = true;
    extraSpecialArgs = {
	    inherit inputs pkgs-unstable isDroid;
    };
    sharedModules = [
	    #inputs.nvf.homeManagerModules.default
    ];
  };
}