{
  inputs,
  #config,
  #lib,
  pkgs,
  pkgs-unstable,
  ...
}:

let

in
{

  #targets.genericLinux.enable = true ; # enable this on non NixOS distro

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "ksvnixospc";
  home.homeDirectory = "/home/ksvnixospc";

  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  #imports = pkgs-unstable.lib.filesystem.listFilesRecursive ./homeModules;

  imports = [
    ./homeModules/vscode-hm.nix
    ./homeModules/shells-hm.nix
    ./homeModules/pay-respects-hm.nix
    ./homeModules/terminals-gui-hm.nix
    ./homeModules/terminal-tools-hm.nix
    ./homeModules/cli-apps-hm.nix
    ./homeModules/gui-apps-hm.nix

  ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages =
    (with pkgs; [
      #stable packages
      kdePackages.partitionmanager
      #warp-terminal

    ])

    ++

      (with pkgs-unstable; [
        #unstable packages

        #kde packages
        kdePackages.kate
        kdePackages.filelight

        #nixd #nix lsp for code editors
        # terminal apps
        vim
        wget
        #wcurl
        nano
        git-town
        #moar # pager like less but modern
        #btop
        #fastfetch
        #bat # cat modern alternative
        tldr # tldr-update is added in services
        lsd
        rip2
        duf
        ripgrep # grep alternative #rg is the command
        ripgrep-all # same as ripgrep but for many file types like video, PDFs, etc etc
        #nh
        gg-jj
        #pay-respects
        #nix-index
        #micro

        # desktop apps
        vlc
        haruna
        euphonica
        freetube
        collector # drag and drop tool
        localsend
        qbittorrent
        qpwgraph

        # audio tool
        #gnome-sound-recorder
        audacity # audio tool app
        #reco # recorder

        brave
        google-chrome
        firefox
        #tor-browser

        #soundwireserver
        podman-desktop
        onlyoffice-desktopeditors
        #virtualbox
        waveterm # modern terminal app
        warp-terminal
        cheese # camera app
        #zoom-us
        n8n

        telegram-desktop
        signal-desktop
        discord

        # vscode
        /*
          (vscode-with-extensions.override {

            vscode = vscode-package;

            vscodeExtensions = vscode-extnsns;
          })
        */

      ]);

  programs = {

    # nix garbage collection
    /*
      programs.nix.gc = {
        automatic = true;
        frequency = "daily";
        options = "--delete-older-than 7d";
        #persistent = false;
        #randomizedDelaySec = "30min";
      };
    */

  };

  services = {

    # home manager auto expire of the generations
    home-manager.autoExpire = {
      enable = true;
      frequency = "daily";
      timestamp = "-3 days";

    };

    # tldr-update
    # tldr package actually declared above
    # this particular below package is for running the update
    tldr-update = {
      enable = true;
      package = pkgs-unstable.tldr;
      period = "weekly"; # default is weekly
    };

    /*
      kdeconnect = {
        enable = true;
        indicator = true;
        package = pkgs-unstable.kdePackages.kdeconnect-kde ;
      };
    */

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
    EDITOR = "micro"; #micro added in cli-apps-hm.nix file
    #MANPAGER = "sh -c 'col -b | bat -l man -p '"; # add -p flag to bat for plain style
    
  };

  home.shellAliases = {
    rm = "echo Use 'rip' instead of rm.";
    rip = "rip --graveyard ~/.local/shareman -psh";
    df = "echo try duf instead";
    grep = "echo 'try ripgrep or ripgrep-all and rg or rga is the command'";
    man = "batman";

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
