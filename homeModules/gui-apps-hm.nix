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
  /*programs.firefox = {
    enable = true;
    package = pkgs-unstable.firefox;
    nativeMessagingHosts.packages = [ pkgs-unstable.firefoxpwa ];

  };*/

  # obs-studio
  programs.obs-studio = {
    enable = true;
    package = pkgs-unstable.obs-studio;
    plugins = with pkgs-unstable.obs-studio-plugins; [
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

}
