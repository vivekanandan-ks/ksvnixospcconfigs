{
  #inputs,
  #config,
  #lib,
  #pkgs,
  pkgs-unstable,
  ...
}:

{

  # firefox
  programs.firefox = {
    enable = true;
    package = pkgs-unstable.firefox;
    nativeMessagingHosts = [ pkgs-unstable.firefoxpwa ];

  };
  # to make sure the package is both in the PATH and in the Firefox's nativeMessagingHosts.
  home.packages = [
    pkgs-unstable.firefoxpwa
  ];

  # obs-studio
  programs.obs-studio = {
    enable = true;
    package = pkgs-unstable.obs-studio;
    plugins = with pkgs-unstable.obs-studio-plugins; [
      obs-composite-blur
      obs-backgroundremoval
      obs-pipewire-audio-capture
      #droidcam-obs
      obs-advanced-masks
      obs-move-transition
      obs-multi-rtmp
      input-overlay

    ];
  };

  services.kdeconnect = {
    enable = true;
    indicator = true;
    package = pkgs-unstable.kdePackages.kdeconnect-kde;
  };

  programs.zapzap = {
    enable = true;
    package = pkgs-unstable.zapzap;
    #settings = {}; # GUI settings changes can be found in $XDG_CONFIG_HOME/ZapZap/ZapZap.conf
  };

}
