{
  #inputs,
  #config,
  #lib,
  #pkgs,
  pkgs-unstable,
  ...
}:

{

  # nix-index (needed to support pay-respects for suggesting nixpkgs)
  programs.nix-index = {
    enable = true;
    package = pkgs-unstable.nix-index;
    enableBashIntegration = true;
    enableFishIntegration = true;
    #nushell integration doesn't exist yet
  };
  #command-not-found.enable = false;

  #pay-respects
  programs.pay-respects = {
    enable = true;
    package = pkgs-unstable.pay-respects;
    #enableBashIntegration = true;
    #enableFishIntegration = true;
    #enableNushellIntegration = true;
    #options = [ "--alias" "f" ]; # by default alias is f in new versions so no need for this option
    #added a home.file below
  };
  #pay-respects config file
  home.file.".config/pay-respects/config.toml" = {
    text = ''
      package_manager.install_method = "Shell"
    '';
  };

}
