{
  inputs,
  config,
  #lib,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  home.packages = 
    
    (with pkgs; [
      # stable packages
      #warp-terminal
      #vesktop
      kdePackages.partitionmanager

    ]) ++
    
    (with pkgs-unstable; [
      #unstable packages
      #kde packages
        kdePackages.kate
        kdePackages.filelight
        #kdePackages.poppler
        kdePackages.tokodon

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
        #rustdesk
        rustdesk-flutter

        telegram-desktop
        signal-desktop
        element-desktop
        #discord
        #vesktop
        thunderbird-latest
        spotube

        # KDE desktop effects addons
        #inputs.kwin-effects-forceblur.packages.${pkgs.system}.default # Wayland
        inputs.kwin-effects-forceblur.packages.${pkgs.stdenv.hostPlatform.system}.default # Wayland
        #inputs.kwin-effects-forceblur.packages.${pkgs.system}.x11 # X11
        #kde-rounded-corners
      

    ]);
}