{
  inputs,
  pkgs,
  pkgs-unstable,
  system,
  ...
}:
let
  pkgs-niri = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
    overlays = [
      inputs.niri.overlays.niri
    ];
  };

in
{

  #importing the niri module
  imports = [
    inputs.niri.homeModules.niri
  ];

  programs.niri = {
    enable = true;
    package = pkgs-niri.niri-stable;
    settings = {

    };

  };

}
