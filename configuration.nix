# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, pkgs-unstable, lib, ... }:

{
  imports = [ 
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    extraSpecialArgs = { inherit inputs pkgs pkgs-unstable ; };
    users = {
      ksvnixospc = import ./home.nix;
    };
    backupFileExtension = "backup";
  };

  #SWAP
  swapDevices = lib.mkForce [ ];
  # If you also want to disable zram (compressed swap in RAM):
  #zramSwap.enable = false;

  #Docker
  #if u are changing the config from root to rootless mode,
  #follow this: https://discourse.nixos.org/t/docker-rootless-containers-are-running-but-not-showing-in-docker-ps/47717
  #Enabling docker in rootless mode.
  #Don't forget to include the below commented commands to start the docker daemon service,
  #coz just enabling doesn't start the daemon
  /*virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };*/
    #systemctl --user enable --now docker
    #systemctl --user start docker
    #systemctl --user status docker # to check the status

  # Podman
  # Enable common container config files in /etc/containers
  virtualisation.containers.enable = true;
  virtualisation = {
    
    podman = {
      enable = true;
      dockerCompat = true;  # Enables the Docker compatibility socket #also creates wrapper alias for docker commands
      dockerSocket.enable = true;  # Creates a Docker-compatible socket
      
      /*#Auto-pruning
      autoPrune = {
        enable = true;
        dates = "weekly";  # When to run: "daily", "weekly", etc.
        flags = [ "--all" "--volumes" ];  # Additional flags
      };
    
      #Container settings
      settings = {
        engine = {
          cgroup_manager = "systemd";  # Use systemd for cgroup management
          events_logger = "journald";  # Log to journald
          runtime = "crun";  # Default runtime
          volume_path = "$HOME/.local/share/containers/storage/volumes";  # Custom volume path
        };*/

      # Default network settings
      defaultNetwork.settings = {
      dns_enabled = true;  # Enable DNS server for containers
      #network_interface = "podman0";  # Default network interface name
    };
    };
  };

  #download buffer size; default size is 16mb (16*1024*1024)
  nix.settings.download-buffer-size = 67108864;

  # Bootloader.
  # systemd-boot
  #boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #limine boot
  boot.loader = {
    limine = {
      enable = true;
      style.wallpapers = lib.filesystem.listFilesRecursive ./limine-images; #list of wallpaper paths
      #style.wallpaperStyle = "centered";
      extraEntries = ''
        /Windows
          protocol: efi
          path: uuid(1c135138-506a-45ed-8352-6455f45e9fea):/EFI/Microsoft/Boot/bootmgfw.efi
      '';
      extraConfig = ''
        remember_last_entry: yes
      '';
    };
  };


  /*#kde-connect
  programs.kdeconnect = lib.mkForce {
    enable = true;
    package = pkgs-unstable.kdePackages.kdeconnect-kde;
  };*/

  #Enable bluetooth
  hardware.bluetooth.enable = true;
  
  #cosmic DE
  #services.displayManager.cosmic-greeter.enable = true; # cosmic login manager
  #services.desktopManager.cosmic.enable = true;

  # enable Hyprland
  #programs.hyprland.enable = true;

  #Enable flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  #enable flatpak
  services.flatpak.enable = true;

  # enable appimage support
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  #enable unfree services
  #nixpkgs.config.allowUnfree = true; #already mentioned in the flake so no need here

  /*#enable fish shell
  /*#enable fish shell
  programs.fish ={
    enable = true;
    package = pkgs-unstable.fish ;
    shellAliases = {
      rm = "echo Use 'rip' instead of rm." ;
      rip = "rip --graveyard ~/.local/share/Trash" ;
    };
  };*/

  /*#enable git
  programs.git = {
    enable = true;
    package = pkgs-unstable.git;
    config = {
      user.name = "vivekanandan-ks";
      user.email = "ksvdevksv@gmail.com";
      init.defaultBranch = "main";
      core.editor = "micro";
    };
  };*/

  /*# Install firefox.
  programs.firefox = {
    enable = true;
    package = pkgs-unstable.firefox;
    policies ={
      DisableTelemetry = true;
      #Homepage.StartPage = "https://google.com";
    };
  };*/

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

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

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

  users.mutableUsers = false; #this will make all user management only via nixos and
  #imperative user creations or anything in kde or commands won't persist the nixos-rebuild command.


  #root password
  users.users.root.hashedPassword = "$6$/Yo/IR.A6rGbFVr6$a6c7yhjPYGuJOBBkcPXl/SjZ531tEUHtkY3tX3np2dcX6JpZg.Myrwdnz.fhqci0Sg83vU8lDYmdpSAQqD.OF0" ;
  # Define a user account
  users.users.ksvnixospc = {
    isNormalUser = true;
    description = "ksvnixospc";
    extraGroups = [ "networkmanager" "wheel" "podman" ];
    hashedPassword = "$6$DmrUUL7YWFMar6aA$sAoRlSbFH/GYETfXGTGa6GSTEsBEP1lQ6oRdXlQUsqhRB7OTI2vTmVlx64B2ihcez8B0q0l8/Vx1pO8c82bxm0" ;
    shell = pkgs-unstable.fish;
    packages = (with pkgs; [
      #stable

    ])

    ++

    (with pkgs-unstable;[
      #unstable
      gh

    ]);
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "ksvnixospc"; 

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages =
    (with pkgs; [
      #stable

    ])

    ++

    (with pkgs-unstable;[
      #unstable
      #inputs.kwin-effects-forceblur.packages.${pkgs-unstable.system}.default # Wayland
      #inputs.kwin-effects-forceblur.packages.${pkgs.system}.x11 # X11

    ]);

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
