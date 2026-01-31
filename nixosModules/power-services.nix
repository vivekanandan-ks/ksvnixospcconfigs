{
  #inputs,
  #config,
  #pkgs,
  pkgs-unstable,
  #lib,
  #nix4vscode,
  #system,
  #username,
  ...
}: {
  services.power-profiles-daemon = {
    enable = true;
    package = pkgs-unstable.power-profiles-daemon;
  };

  services.upower = {
    enable = true;
    package = pkgs-unstable.upower;
  };
}
