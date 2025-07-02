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
      vim
      wget
      nano
      micro
      git-town
      btop
      fastfetch
      bat
      vlc
      haruna
      collector
      localsend
      tldr
      lsd
      rip2
      nh
      brave
      waveterm
      #tor-browser
      #soundwireserver
      signal-desktop
      #podman-desktop
      discord
      onlyoffice-desktopeditors
      freetube
      #virtualbox
      cheese
      #zoom-us
      telegram-desktop
      #nushell
      jujutsu gg-jj
      google-chrome
      vscode
      kdePackages.kate
      

    ]);

  programs = {

    #bash
    bash = {
      enable = true ;
    };

    #fish
    fish = {
      enable = true ;
      package = pkgs-unstable.fish ;
      shellAliases = {
        rm = "echo Use 'rip' instead of rm." ;
        rip = "rip --graveyard ~/.local/share/Trash" ;
      };
    };

    #git
    git = {
      enable = true ;
      package = pkgs-unstable.git;
      extraConfig = {
        user.name = "vivekanandan-ks";
        user.email = "ksvdevksv@gmail.com";
        init.defaultBranch = "main";
        core.editor = "micro";
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
          $shell $nix_shell $directory $git_branch $cmd_duration
          $character
        '';

        character = {
          success_symbol = "[>](bold fg:green) ";
          error_symbol = "[>](bold fg:red) ";
        };

        package = {
          disabled = false;
        };

        git_branch = {
          style = "bg: green";
          symbol = "󰘬";
          truncation_length = 4;
          truncation_symbol = "";
          format = "• [](bold fg:green)[$symbol $branch(:$remote_branch)](fg:black bg:green)[ ](bold fg:green)";
        };
    
        git_commit = {
          commit_hash_length = 4;
          tag_symbol = " ";
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
        };

        scan_timeout = 10;
        /*character = {
          success_symbol = "➜";
          error_symbol = "➜";
        };*/
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
      };

      #extraConfig = '''';

    };    



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
    # EDITOR = "micro";
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
