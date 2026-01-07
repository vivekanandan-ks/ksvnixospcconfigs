# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  inputs,
  #config,
  pkgs,
  pkgs-unstable,
  lib,
  nix4vscode,
  system,
  isDroid,
  username,
  ...
}:

{
  imports = [

    #./hardware-configuration.nix # Include the results of the hardware scan.
    inputs.home-manager.nixosModules.home-manager
    #inputs.sops-nix.nixosModules.sops
    #./nixosModules/jellyfin-nixos.nix
    #./nixosModules/peertube.nix
    ./nixosModules/graphics.nix
    ./nixosModules/ssh.nix
    ./nixosModules/virtualisation.nix

    # stylix
    # for some reason some options aren't working when I use stylix with nixosModules
    # but works good when used as homeModule in home.nix
    #inputs.stylix.nixosModules.stylix
    #./nixosModules/stylix.nix

  ];

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
        ;
    };
    #users.ksvnixospc = import ./home.nix;
    #users.ksvnixospc = {
    users."${username}" = {
      imports = [
        ./home.nix
      ];
    };
    #backupFileExtension = "bak";
    backupFileExtension = lib.mkForce null;
    backupCommand = "sh -c 'mv $0 $0.backup-$(date +%s)'";
    sharedModules = [
      #inputs.stylix.homeModules.stylix
      #inputs.nvf.homeManagerModules.default
      #inputs.sops-nix.homeManagerModules.sops
    ];
  };

  # niri
  /*
    programs.niri = {
      enable = true;
      package = pkgs-unstable.niri;
    };
  */

  # sops
  /*
    sops = {
      defaultSopsFile = ./secrets/secrets.yaml;
      defaultSopsFormat = "yaml";
      age.keyFile = "/home/ksvnixospc/.config/sops/age/keys.txt";
    };
  */

  #fonts
  fonts.packages = with pkgs; [
    nerd-fonts.monofur

  ];

  #SWAP
  swapDevices = lib.mkForce [ ];
  # If you also want to disable zram (compressed swap in RAM):
  #zramSwap.enable = false;

  # n8n
  /*
    services.n8n = {
      enable = true;
      #openFirewall = true;
    };
  */


  # download buffer size; default size is 16mb (16*1024*1024)
  nix.settings.download-buffer-size = 6710886400;

  nix.settings.auto-optimise-store = true; # if set to false(default) then run " nix-store --optimise " periodically to get rid of duplicate files.
  # Nix GC
  /*
    nix.gc = {
      automatic = true;
      #persistent = false;
      dates = "daily";
      options = "--delete-older-than 7d";
      #randomizedDelaySec = "30min";
    };
  */

  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };

  # Bootloader.
  # systemd-boot
  #boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # limine boot # this config moved to hosts folder
  #boot.loader = {
  #  limine = {
  #    enable = true;
  #    style.wallpapers = lib.filesystem.listFilesRecursive ./nixosModules/nixosResources/limine-images; # list of wallpaper paths
  #    #style.wallpaperStyle = "centered";
  #    /*
  #      extraEntries = ''
  #        /Windows
  #          protocol: efi
  #          path: uuid(1c135138-506a-45ed-8352-6455f45e9fea):/EFI/Microsoft/Boot/bootmgfw.efi
  #      '';
  #    */
  #
  #    extraConfig = ''
  #      remember_last_entry: yes
  #    '';
  #  };
  #};

  # kde-connect
  /*
    programs.kdeconnect = lib.mkForce {
      enable = true;
      package = pkgs-unstable.kdePackages.kdeconnect-kde;
    };
  */

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  /*
    # Enable intel graphics harware acceleration (this is supposed to solve the CPUoverheating issues while using camera)
    # refer this: https://wiki.nixos.org/wiki/Accelerated_Video_Playback#Intel
    # refer: https://discourse.nixos.org/t/help-to-solve-cpu-peaks-overheats-while-using-camera-possibly-hw-acceleration-i-guess/68591/1
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs-unstable; [
        #intel-media-driver # For Broadwell (2014) or newer processors. LIBVA_DRIVER_NAME=iHD
        intel-vaapi-driver # For older processors. LIBVA_DRIVER_NAME=i965
        #intel-ocl # looks like this is useful for running LLMs
      ];
    };
    environment.sessionVariables = {
      #LIBVA_DRIVER_NAME = "iHD";
      LIBVA_DRIVER_NAME = "i965";
    }; # Optionally, set the environment variable
  */

  # cosmic DE
  #services.displayManager.cosmic-greeter.enable = true; # cosmic login manager
  #services.desktopManager.cosmic.enable = true;

  # enable Hyprland

  /*
    programs.hyprland = let
      hyprland-pkg = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system} ;
     in {
      enable = true;
      package = hyprland-pkg.hyprland;
      #package = null; # doesn't work in nixos options
      portalPackage = hyprland-pkg.xdg-desktop-portal-hyprland;
      #portalPackage = null; # # doesn't work in nixos options

    };
  */

  #Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  #enable flatpak
  services.flatpak.enable = true;

  # enable appimage support
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  # enable unfree services
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true;
  /*
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "warp-terminal"
    ];
  */

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  /*
    specialisation = {
      kdeunstable.configuration =
        let
          nixpkgs.pkgs = inputs.nixpkgs-unstable;
        in
      {
        # Enable the KDE Plasma Desktop Environment.
        services.displayManager.sddm.enable = true;
        services.desktopManager.plasma6.enable = true;

      };

    };
  */

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  #security.pam.services.sddm.enableKwallet = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  users.mutableUsers = false; # this will make all user management only via nixos and
  #imperative user creations or anything in kde or commands won't persist the nixos-rebuild command.

  #root password
  users.users.root.hashedPassword = "$6$/Yo/IR.A6rGbFVr6$a6c7yhjPYGuJOBBkcPXl/SjZ531tEUHtkY3tX3np2dcX6JpZg.Myrwdnz.fhqci0Sg83vU8lDYmdpSAQqD.OF0";
  # Define a user account
  users.users."${username}" = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    hashedPassword = "$6$DmrUUL7YWFMar6aA$sAoRlSbFH/GYETfXGTGa6GSTEsBEP1lQ6oRdXlQUsqhRB7OTI2vTmVlx64B2ihcez8B0q0l8/Vx1pO8c82bxm0";
    shell = pkgs-unstable.nushell;
    packages =
      (with pkgs; [
        #stable

      ])

      ++

        (with pkgs-unstable; [
          #unstable
          gh

        ]);
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = username;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages =
    (with pkgs; [
      #stable

    ])

    ++

      (with pkgs-unstable; [
        #unstable

      ])

    ++

      [
        #inputs.kwin-effects-forceblur.packages.${pkgs.system}.default # Wayland
        #inputs.kwin-effects-forceblur.packages.${pkgs.system}.x11 # X11
      ];

  # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
