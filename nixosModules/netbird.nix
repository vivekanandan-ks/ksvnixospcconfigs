{
  #inputs,
  #config,
  #pkgs,
  pkgs-unstable,
  #lib,
  #nix4vscode,
  #system,
  ...
}: {

  services.netbird = {
    enable = true;
    package = pkgs-unstable.netbird;
    ui = {
      enable = true;
      package = pkgs-unstable.netbird-ui;
    };
  };
}