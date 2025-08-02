{ config, lib, pkgs, pkgs-unstable, ... }:

let
  globalShellInit = 
    let
      figlet-font.bloody = ./resources/figlet-font-Bloody.flf;
    in
  ''
    #${pkgs.figlet}/bin/figlet -f ${figlet-font.bloody} "hello ksv" | ${pkgs.lolcat}/bin/lolcat
    #${pkgs.figlet}/bin/figlet -f ${figlet-font.bloody} "hello ksv" | sed 's/^/\x1b[38;2;144;202;249m/' | sed 's/$/\x1b[0m/'
    #${pkgs-unstable.fastfetch}/bin/fastfetch
  '';

in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "ksvnixospc";
  home.homeDirectory = "/home/ksvnixospc";

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = (with pkgs; [
      #stable
      kdePackages.partitionmanager
      warp-terminal

    ])

    ++

    (with pkgs-unstable;[
      #unstable

      #kde packages
      kdePackages.kate
      kdePackages.filelight
      
      /*terminal apps*/
      vim
      wget
      nano
      git-town
      btop
      #fastfetch
      bat # cat modern alternative
      tldr #alt for man
      lsd
      rip2
      duf
      ripgrep #grep alternative #rg is the command
      ripgrep-all # same as ripgrep but for many file types like video, PDFs, etc etc
      #nh
      gg-jj

      /*desktop apps*/
      vlc
      haruna
      euphonica
      freetube
      collector #drag and drop tool
      localsend
      qbittorrent
      
      brave
      google-chrome
      #tor-browser

      #soundwireserver
      #podman-desktop
      onlyoffice-desktopeditors
      #virtualbox
      waveterm # modern terminal app
      cheese #camera app
      #zoom-us
      vscode
      
      telegram-desktop
      signal-desktop
      discord

    ]);

  programs = {

    /*#waveterm - modern terminal app
    waveterm = {
      enable = true;
      package = pkgs-unstable.waveterm;
      
      bookmarks = {
        "bookmark@google" = {
          title = "Google";
          url = "https://www.google.com";
        };
      };

      settings = {
        #"window:blur" = true;
        #"window:opacity" = 0.5;
      };
    };*/

    #nix helper
    nh = {
      enable = true;
      package = pkgs-unstable.nh;
      clean = {
        enable = true;
        dates = "daily";
        extraArgs = "--keep 5 --keep-since 3d";
      };
    };

    #fastfetch
    fastfetch = {
      enable = true;
      package = pkgs-unstable.fastfetch;
      settings = builtins.fromJSON (builtins.readFile ./resources/fastfetch-settings.json);
    };

    #nix garbage collection
    /*nix.gc = {
      automatic = true;
      frequency = "daily";
      options = "--delete-older-than 7d";
      #persistent = false;
      #randomizedDelaySec = "30min";
    };*/

    #micro - editor
    micro = {
      enable = true;
      package = pkgs-unstable.micro;
      settings = {

      };
    };

    #bash
    bash = {
      enable = true ;
      initExtra = ''
        ${globalShellInit}
      '';
    };

    #fish
    fish = {
      enable = true ;
      package = pkgs-unstable.fish ;
      /*shellAliases = {
        rm = "echo Use 'rip' instead of rm." ;
        rip = "rip --graveyard ~/.local/share/Trash" ;
      };*/
      interactiveShellInit = ''
        ${globalShellInit}
      '';
    };

    #git
    git = {
      enable = true ;
      package = pkgs-unstable.git;
      extraConfig = {
        user.name = "vivekanandan-ks";
        user.email = "ksvdevksv@gmail.com";
        init.defaultBranch = "main";
        #core.editor = "nano";
      };
    };

    #jujutsu
    jujutsu = {
      enable = true;
      package = pkgs-unstable.jujutsu;
      settings = {
        user = {
          email = "ksvdevksv@gmail.com";
          name = "vivekanandan-ks";
        };
        #ui.editor = "micro";
        snapshot.max-new-file-size = "10MiB"; #https://github.com/jj-vcs/jj/blob/main/docs/config.md#maximum-size-for-new-files
      };
    };

    #firefox
    firefox = {
      enable = true ;
      package = pkgs-unstable.firefox;
      policies ={
        DisableTelemetry = true;
        #Homepage.StartPage = "https://google.com";
      };
    };
    
    /*#github
    gh = {
      enable = true ;
      package = pkgs-unstable.gh;
      #gitCredentialHelper = {
        #enable = true ;
        #hosts = [];  
      #};
    };*/

    #carapace
    carapace = {
      enable = true;
      package = pkgs-unstable.carapace;
      enableNushellIntegration = true;
      enableBashIntegration = true;
      # enableFishIntegration = true; 
      #fish already have it's own features so commenting this for now
    };

    #starship
    starship = {
      enable = true;
      package = pkgs-unstable.starship;
      #enableInteractive = false; #see HM option page before uncommenting
      enableNushellIntegration = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      #uncomment only on eof the following settings
      settings = builtins.fromTOML (builtins.readFile ./resources/starship-themes/pastel-powerline.toml);
      #settings = builtins.fromTOML (builtins.readFile ./resources/starship-themes/catppuccin_macchiato.toml);
      #settings = builtins.fromTOML (builtins.readFile ./resources/starship-themes/catppuccin_frappe.toml);
      #settings = builtins.fromTOML (builtins.readFile ./resources/starship-themes/catppuccin_mocha);
      #settings = builtins.fromTOML (builtins.readFile ./resources/starship-themes/catppuccin_latte.toml);
      #settings = builtins.fromTOML (builtins.readFile ./resources/starship-themes/gruvbox-rainbow.toml);
      #settings = builtins.fromTOML (builtins.readFile ./resources/starship-themes/tokyo-night.toml);
      #settings = builtins.fromTOML (builtins.readFile ./resources/starship-themes/nerd-font-symbols.toml);

    };

    #nushell
    nushell = {
      enable = true ;
      package = pkgs-unstable.nushell;
      plugins = with pkgs-unstable; [
        #nushellPlugins.gstat
      ];
      settings = {
        #show_banner = false;
        highlight_resolved_externals = true;
        completions.external = {
          enable = true;
          max_results = 200;
        };
        history = {
          max_size = 10000;
        };
        color_config = {
          shape_external = "red"; # color of unresolved externals (see 'ansi --list')
          shape_external_resolved = "white"; # color of resolved externals 
        };
      };

      extraConfig = ''
        $env.config.hooks.command_not_found = [
          {|cmd| ^command-not-found $cmd | print }  
        ]

        ${globalShellInit}     
      '';
        /*# Add your shell init command here
        $env.config.hooks.pre_prompt = [
          {||
            #some commanda here
          }
        ]
      '';*/

    };

    #atuin - shell history and sync e2ee to my atuin account
    atuin = {
      enable = true;
      package = pkgs-unstable.atuin;
      enableNushellIntegration = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      flags = [
        "--disable-up-arrow"
        #"--disable-ctrl-r"
      ];
      #check this out for settings options: https://docs.atuin.sh/configuration/config/
      settings = {
        auto_sync = true;
        sync_frequency = "1m";
        sync.records = true;
        search_mode = "prefix";
        style = "auto";
        inline_height = 40; # default 40
        show_preview = true;
        theme = {
          name = "marine"; # options are ""(default) or "autumn" or "marine"(good out of the three)
          debug = true;
        };
      };
    };

    # nix-index
    nix-index = {
      enable = true;
      package = pkgs-unstable.nix-index;
      enableBashIntegration = true;
      enableFishIntegration = true;
      #nushell integration doesn't exist yet
    };

    #obs-studio
    obs-studio = {
      enable = true;
      package = pkgs-unstable.obs-studio;
      plugins = with pkgs-unstable.obs-studio-plugins;[
        obs-composite-blur
        obs-backgroundremoval
        obs-pipewire-audio-capture
        droidcam-obs
        obs-advanced-masks
        obs-move-transition
        obs-multi-rtmp
        input-overlay

      ];
    };



  };

  services = {
    
    /*kdeconnect = {
      enable = true;
      indicator = true;
      package = pkgs-unstable.kdePackages.kdeconnect-kde ; 
    };*/

  };

  home.shellAliases = {
    rm = "echo Use 'rip' instead of rm." ;
    rip = "rip --graveyard ~/.local/share/Trash" ;
    df = "echo try duf instead";
    grep = "echo 'try ripgrep or ripgrep-all and rg or rga is the command'";

  };

  #pay-respects
  programs.pay-respects = {
    enable = true;
    package = pkgs-unstable.pay-respects;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableNushellIntegration = true;
    options = [ 
      "--alias" "f"
    ];
    #added a home.file below
  };
  #pay-respects config file
  home.file.".config/pay-respects/config.toml" = {
      text = ''
        package_manager.install_method = "Shell"
      '';
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/ksvnixospc/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "micro";
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
