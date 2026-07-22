{config, ...}: {
  flake.nixosModules.configuration = {
    inputs,
    #config,
    pkgs,
    pkgs-unstable,
    lib,
    nix4vscode,
    system,
    isDroid ? false,
    username,
    self,
    ...
  }: {
    imports = [
      #./hardware-configuration.nix # Include the results of the hardware scan.
      #inputs.home-manager.nixosModules.home-manager
      #inputs.sops-nix.nixosModules.sops
      #./nixosModules/jellyfin-nixos.nix
      #./nixosModules/peertube.nix
    ];

    #fonts
    fonts.packages = with pkgs; [
      nerd-fonts.monofur
    ];

    #SWAP
    swapDevices = lib.mkForce [];
    # If you also want to disable zram (compressed swap in RAM):
    #zramSwap.enable = false;

    # Bootloader.
    # systemd-boot
    #boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = false; # making this to false helps avoid the nixos-rebuild error in akashnixospc

    # kde-connect
    programs.kdeconnect =
      /*
      lib.mkForce
      */
      {
        enable = true;
        package = lib.mkForce pkgs-unstable.kdePackages.kdeconnect-kde;
      };

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

    #networking.hostName = "nixos"; # Define your hostname.
    #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networking.networkmanager.enable = true;

    #enabling for impala
    # networking.wireless.iwd = {
    #   enable = true;
    #   package = pkgs-unstable.iwd;
    # };
    # networking.networkmanager.wifi.backend = "iwd";

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

    #programs.fish.enable = true;


    # Enable automatic login for the user.
    services.displayManager.autoLogin.enable = true;
    services.displayManager.autoLogin.user = username;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages =
      (with pkgs; [
        #stable
      ])
      ++ (with pkgs-unstable; [
        #unstable
      ])
      ++ [
        #inputs.kwin-effects-forceblur.packages.${pkgs.stdenv.hostPlatform.system}.default # Wayland
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
  };
}
