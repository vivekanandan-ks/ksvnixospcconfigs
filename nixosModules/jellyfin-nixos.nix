{
  #inputs,
  #config,
  #pkgs,
  pkgs-unstable,
  #lib,
  #nix4vscode,
  #system,
  ...
}:
{


  environment.systemPackages = with pkgs-unstable; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];

  # jellyfin server
  services.jellyfin = {
    enable = true;
    package = pkgs-unstable.jellyfin;
    openFirewall = true;
    user="ksvnixospc";
  };

}

# check this out 
# separate flake for jellyfin with more options:
# https://github.com/Sveske-Juice/declarative-jellyfin