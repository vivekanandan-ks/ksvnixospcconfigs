_: {
  flake.homeModules.common.fish = {
    #inputs,
    #config,
    #lib,
    pkgs,
    pkgs-unstable,
    ...
  }: let
    globalShellInit = let
      figlet-font.bloody = ../../hmResources/figlet-font-Bloody.flf;
    in ''
      #${pkgs.figlet}/bin/figlet -f ${figlet-font.bloody} "hello ksv" | ${pkgs.lolcat}/bin/lolcat
      #${pkgs.figlet}/bin/figlet -f ${figlet-font.bloody} "hello ksv" | sed 's/^/\x1b[38;2;144;202;249m/' | sed 's/$/\x1b[0m/'
      #${pkgs-unstable.fastfetch}/bin/fastfetch
    '';
  in {
    programs.fish = {
      enable = true;
      package = pkgs-unstable.fish;
      /*
      shellAliases = {
        rm = "echo Use 'rip' instead of rm." ;
        rip = "rip --graveyard ~/.local/share/Trash" ;
      };
      */
      interactiveShellInit = ''
        ${globalShellInit}
      '';
      #try shellInit if below option isn't your preference
      shellInitLast = ''
        #pay-respects fish | source
      '';
    };
  };
}
