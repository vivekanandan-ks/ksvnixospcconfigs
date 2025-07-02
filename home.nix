{ config, pkgs, pkgs-unstable, ... }:

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
      enable = true ;
      package = pkgs-unstable.carapace ;
      enableNushellIntegration = true ;
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
      
      extraConfig = ''
        # --- Git Branch Function ---
        def get-git-branch [] {
            let git_status = (git status --porcelain -b --ignore-submodules 2>/dev/null | lines)

            if ($git_status | is-empty) {
                return ""
            }

            let branch_line = ($git_status | item 0)
            let branch_name = ($branch_line | split row " " | item 1 | str replace "..." "")

            let cleaned_branch = ($branch_name | str replace --regex "^\S+/" "")

            if ($cleaned_branch | is-empty) { # Check if cleaned_branch is empty
                let commit_hash = (git rev-parse --short HEAD 2>/dev/null | trim)
                return $"($"HEAD" ($commit_hash)")"
            } else {
                return $"($"(" ($cleaned_branch)")")"
            }
        }

        # --- Prompt Configuration ---
        $env.PROMPT_COMMAND = {||
            let cwd = (pwd | path basename)
            let branch = (get-git-branch)
            let user = ($env.USER)
            let hostname = ($env.HOSTNAME)

            # Using different colors for better readability
            # You can adjust these colors
            let user_host_part = $"($user | ansi blue)@($hostname | ansi blue)"
            let path_part = $" (~/($cwd) | ansi green)"
            let branch_part = (if ($branch | is-empty) { "" } { $"($branch | ansi yellow)" }) # Only show if branch exists
            let prompt_end = "> " # Always end with a prompt symbol

            # Combine all parts
            $"($user_host_part)($path_part)($branch_part)($prompt_end)"
        }

        $env.PROMPT_COMMAND_RIGHT = {||
            "" # No right prompt
        }

        # You might also want to set your LS_COLORS for better file highlighting
        # $env.LS_COLORS = (ls-colors)
      '';

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
