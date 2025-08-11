{
  #inputs,
  #config,
  #lib,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  globalShellInit =
    let
      figlet-font.bloody = ./hmResources/figlet-font-Bloody.flf;
    in
    ''
      #${pkgs.figlet}/bin/figlet -f ${figlet-font.bloody} "hello ksv" | ${pkgs.lolcat}/bin/lolcat
      #${pkgs.figlet}/bin/figlet -f ${figlet-font.bloody} "hello ksv" | sed 's/^/\x1b[38;2;144;202;249m/' | sed 's/$/\x1b[0m/'
      #${pkgs-unstable.fastfetch}/bin/fastfetch
    '';

in
{
  programs = {
    #bash
    bash = {
      enable = true;
      initExtra = ''
        #eval "$(pay-respects bash)"
        ${globalShellInit}

      '';
    };

    #fish
    fish = {
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

    #nushell
    nushell = {
      enable = true;
      package = pkgs-unstable.nushell;
      plugins = with pkgs-unstable.nushellPlugins; [
        gstat
        #net
        hcl
        skim
        query
        highlight

      ];
      settings = {
        #show_banner = false;
        highlight_resolved_externals = true;
        completions.external = {
          enable = true;
          max_results = 200;
        };
        history = {
          max_size = 10000;
        };
        color_config = {
          shape_external = "red"; # color of unresolved externals (see 'ansi --list')
          shape_external_resolved = "white"; # color of resolved externals
        };
      };

      extraConfig = ''
        $env.config.hooks.command_not_found = [
          {|cmd| ^command-not-found $cmd | print }  
        ]

        #pay-respects nushell
        ${globalShellInit}     
      '';
      /*
        # Add your shell init command here
          $env.config.hooks.pre_prompt = [
            {||
              #some commanda here
            }
          ]
        '';
      */

    };

  };

}
