{ config, lib, pkgs, pkgs-unstable, ... }:

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
      fastfetch
      bat # cat modern alternative
      tldr #alt for man
      lsd
      rip2
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
        extraArgs = "--keep 5 --keep-since 5d";
      };
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
        echo "       
          ██░ ██ ▓█████  ██▓     ██▓     ▒█████      ██ ▄█▀  ██████ ██▒   █▓
          ▓██░ ██▒▓█   ▀ ▓██▒    ▓██▒    ▒██▒  ██▒    ██▄█▒ ▒██    ▒▓██░   █▒
          ▒██▀▀██░▒███   ▒██░    ▒██░    ▒██░  ██▒   ▓███▄░ ░ ▓██▄   ▓██  █▒░
          ░▓█ ░██ ▒▓█  ▄ ▒██░    ▒██░    ▒██   ██░   ▓██ █▄   ▒   ██▒ ▒██ █░░
          ░▓█▒░██▓░▒████▒░██████▒░██████▒░ ████▓▒░   ▒██▒ █▄▒██████▒▒  ▒▀█░  
          ▒ ░░▒░▒░░ ▒░ ░░ ▒░▓  ░░ ▒░▓  ░░ ▒░▒░▒░    ▒ ▒▒ ▓▒▒ ▒▓▒ ▒ ░  ░ ▐░  
          ▒ ░▒░ ░ ░ ░  ░░ ░ ▒  ░░ ░ ▒  ░  ░ ▒ ▒░    ░ ░▒ ▒░░ ░▒  ░ ░  ░ ░░  
          ░  ░░ ░   ░     ░ ░     ░ ░   ░ ░ ░ ▒     ░ ░░ ░ ░  ░  ░      ░░  
          ░  ░  ░   ░  ░    ░  ░    ░  ░    ░ ░     ░  ░         ░       ░  
                                                                        ░   
        " | ${pkgs.lolcat}/bin/lolcat
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
      settings = {

        add_newline = false;

        format = ''
          $shell $nix_shell $directory $git_branch $git_status $package $cmd_duration
          $character
        '';

        character = {
          success_symbol = "[>>>](bold fg:green) ";
          error_symbol = "[>>>](bold fg:red) ";
        };

        package = {
          disabled = false;
        };

        /*git_branch = {
          #style = "bg: green";
          symbol = "⤴️";
          truncation_length = 4;
          truncation_symbol = "";
          format = "• [](bold fg:green)[$symbol $branch(:$remote_branch)](fg:black bg:green)[](bold fg:green)";
        };
    
        git_commit = {
          #commit_hash_length = 4;
          tag_symbol = "✅";
        };
    
        git_state = {
          format = ''[\($state( $progress_current of $progress_total)\)]($style) '';
          cherry_pick = "[🍒 PICKING](bold red)";
        };
    
        git_status = {
          conflicted = " 🏳 ";
          ahead = " 🏎💨 ";
          behind = " 😰 ";
          diverged = " 😵 ";
          untracked = " 🤷 ‍";
          stashed = " 📦 ";
          modified = " 📝 ";
          staged = "[++($count)](green)";
          renamed = " ✍️ ";
          deleted = " 🗑 ";
        };*/

        scan_timeout = 10;
  
      };
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
      '';

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
