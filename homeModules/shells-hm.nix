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
        #gstat
        #net
        #hcl
        #skim
        #query
        #highlight

      ];
      settings = {
        show_banner = false;
        highlight_resolved_externals = true;
        completions.external = {
          enable = true;
          max_results = 200;
          #completer = "$external_completer"; # defined in extra config below # not sure if assigning this is right so commenting and adding in config below
          # $env.config.completions.external.completer : $external_completer
        };
        history = {
          max_size = 10000;
        };
        color_config = {
          shape_external = "red"; # color of unresolved externals (see 'ansi --list')
          shape_external_resolved = "white"; # color of resolved externals
        };
        cursor_shape.emacs = "line";
        # better use explore instead instead if below gimmick for pager
        #hooks.display_output = "table -e --width 1000 | less -FSRX";
        #hooks.display_output = "table -e --width 1000 | less -FSR";
        #hooks.display_output = "table -e --width 1000 | less -FS";
        #hooks.display_output = "table -e --width 1000 | less -SRX";
        #hooks.display_output = "table -e --width 1000";
      };

      extraConfig = /* nu */ ''
        $env.config.hooks.command_not_found = [
          {|cmd| ^command-not-found $cmd | print }
        ]

        $env.config.hooks.env_change = {
          PWD: [{|before, after| print $"changing directory from (ansi blue_underline )($'($before)' | ansi link )(ansi reset) to (ansi green_underline)($'($after)' | ansi link )(ansi reset)" }]
        }

        # upsert method
        #$env.config.hooks = ($env.config.hooks | upsert display_output {
        #  {if (term size).columns >= 100 { table -ed 1 } else { table }
        #})

        # merge method
        #$env.config.hooks = ($env.config.hooks | merge {
        #  display_output: {if (term size).columns >= 100 { table -ed 1 } else { table }
        #})
        # both methods syntax explained
        #{} | upsert name value
        #{} | merge { name: value }
        # ok so in my case:
        #{} | upsert name { {value} } # {{}} needed because of closure property
        #{} | merge { name: {value} }

        if true {
          const mime_to_lang = {
            application/json: json,
            application/xml: xml,
            application/yaml: yaml,
            text/csv: csv,
            text/tab-separated-values: tsv,
            text/x-toml: toml,
            text/x-rust: rust,
          }

          $env.config.hooks.display_output = {
            metadata access {|meta|
              match $meta.content_type? {
                null => {},
                "application/x-nuscript" | "application/x-nuon" | "text/x-nushell" => { if (config use-colors) { nu-highlight } else {} },
                "text/markdown" => { CLICOLOR_FORCE=1 PAGER="less -r" ^glow -p -s dark - },
                $mime if $mime in $mime_to_lang => { ^bat -Ppf --language=($mime_to_lang | get $mime) },
                _ => {},
              }
            } | table -e
          }
        }

        let fish_completer = {|spans|
          fish --command $"complete '--do-complete=($spans | str replace --all "'" "\\'" | str join ' ')'"
          | from tsv --flexible --noheaders --no-infer
          | rename value description
          | update value {|row|
          let value = $row.value
          let need_quote = ['\' ',' '[' ']' '(' ')' ' ' '\t' "'" '"' "`"] | any {$in in $value}
          if ($need_quote and ($value | path exists)) {
            let expanded_path = if ($value starts-with ~) {$value | path expand --no-symlink} else {$value}
            $'"($expanded_path | str replace --all "\"" "\\\"")"'
            } else {$value}
          }
        }

        let carapace_completer = {|spans: list<string>|
          carapace $spans.0 nushell ...$spans
          | from json
          | if ($in | default [] | where value =~ '^-.*ERR$' | is-empty) { $in } else { null }
        }

        # This completer will use carapace by default
        let external_completer = {|spans|
          let expanded_alias = scope aliases
          | where name == $spans.0
          | get -o 0.expansion

          let spans = if $expanded_alias != null {
            $spans
            | skip 1
            | prepend ($expanded_alias | split row ' ' | take 1)
          } else {
            $spans
          }

          match $spans.0 {
            # carapace completions are incorrect for nu
            nu => $fish_completer
            # fish completes commits and branch names in a nicer way
            git => $fish_completer
            # carapace doesn't have completions for asdf
            asdf => $fish_completer
            #_ => $carapace_completer
            _ => $fish_completer
          } | do $in $spans
        }

        $env.config.completions.external.completer = $external_completer

        $env.config.hooks.pre_prompt ++= [
          { # atuin history to nushell history
            history --clear ; atuin history list --format "{command}\t{directory}" |
            lines | split column "\t" command cwd | history import
          }
          {
            # Clean up backup files
            try { ls ~/.config/nushell/history.txt.bak* } | each { |file| ^rm $file.name } | ignore
          }
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
      extraEnv = ''
        # dummy line added just for sake of immutable symlink file generated by nix
        # so that we can't change behaviour through imperative methods
      '';

    };

  };
  home.packages = [
    pkgs-unstable.glow # for nushell displayoutput hook to highlight markdown
  ];
  home.shell.enableNushellIntegration = true;

}
