{
  #inputs,
  #config,
  #lib,
  #pkgs,
  pkgs-unstable,
  ...
}:

{
  services.tailscale-systray = {
    enable = true;
    package = pkgs-unstable.tailscale;
  };
}