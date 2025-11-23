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
    #inputs.sops-nix.homeManagerModules.sops # for standalone home manager (not for nixos HM integration)
    ./homeModules/vscode-hm.nix
    ./homeModules/shells-hm.nix
    #./homeModules/pay-respects-hm.nix
    ./homeModules/terminals-gui-hm.nix
    ./homeModules/terminal-tools-hm.nix
    ./homeModules/cli-apps-hm.nix
    ./homeModules/gui-apps-hm.nix
    ./homeModules/micro-editor-hm.nix
    ./homeModules/nvf-hm.nix
    ./homeModules/mpv-hm.nix
    ./homeModules/zed-editor-hm.nix
    ./homeModules/mcp-hm.nix
    ./homeModules/flatpak-hm.nix

    # WMs
    #./homeModules/niri-hm.nix
    #./homeModules/hyprland-hm.nix

  ];

  # sops
  /*
    sops = {
      defaultSopsFile = ./secrets/secrets.yaml;
      defaultSopsFormat = "yaml";
      age.keyFile = "/home/ksvnixospc/.config/sops/age/keys.txt";
    };
    systemd.user.services.mbsync.unitConfig.After = [ "sops-nix.service" ];  # refer: https://github.com/Mic92/sops-nix#use-with-home-manager
  */

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
        #kdePackages.poppler

        poppler-utils

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
        #gg-jj
        #nix-index
        #micro
        wakatime-cli

        # desktop apps
        vlc
        #haruna
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
        #firefox # declared as options in gui-apps-hm.nix
        #tor-browser

        #soundwireserver
        podman-desktop
        onlyoffice-desktopeditors
        #virtualbox
        waveterm # modern terminal app
        warp-terminal
        cheese # camera app
        #zoom-us
        #n8n

        telegram-desktop
        signal-desktop
        #element-desktop
        #discord
        vesktop
        thunderbird-latest

        # KDE desktop effects addons
        inputs.kwin-effects-forceblur.packages.${pkgs.system}.default # Wayland
        #inputs.kwin-effects-forceblur.packages.${pkgs.system}.x11 # X11
        #kde-rounded-corners

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

    command-not-found.enable = true; # this provides the suggestions command by default in nix

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

    # this program persist the clipboard contents from wayland apps even if the apps are closed
    wl-clip-persist = {
      enable = true;
      package = pkgs-unstable.wl-clip-persist;

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
    EDITOR = "nvim";
    #MANPAGER = "sh -c 'col -b | bat -l man -p '"; # add -p flag to bat for plain style
    #MANPAGER = "nvim +Man! +only";

  };

  home.shellAliases = {
    rm = "echo Use 'rip' instead of rm.";
    rip = "rip --graveyard ~/.local/share/Trash/files/rip2trash";
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
