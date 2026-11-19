_: {
  flake.homeModules.common.nu = {
    #inputs,
    #config,
    #lib,
    #pkgs,
    pkgs-unstable,
    ...
  }: {
    programs.nushell =
      /*
      let
        inshellisense-nu-init =
          pkgs.runCommand "inshellisense-init.nu" {
            nativeBuildInputs = [pkgs-unstable.inshellisense];
          } ''
            # Set a fake HOME to satisfy node/inshellisense during build
            export HOME=$(mktemp -d)
            ${pkgs-unstable.inshellisense}/bin/is init nu > $out
          '';
      in
      */
      {
        enable = true;
        package = pkgs-unstable.nushell;
        loadSessionVariables = true;
        /*
          plugins = with pkgs-unstable.nushellPlugins; [
          #gstat
          #net
          #hcl
          #skim
          #query
          #highlight
        ];
        */
        settings = {
          show_banner = false;
          highlight_resolved_externals = true;
          edit_mode = "helix";
          # auto_pairs requires Nushell 0.117.0+ (uncomment when nixpkgs updates past 0.116.1)
          # auto_pairs = {
          #   enable = true;
          #   pairs = ["()" "[]" "{}" "\"\"" "''" "``"];
          # };
          tui = {
            border_type = "rounded";
          };
          completions = {
            persistent_menus = true;
            external = {
              enable = true;
              max_results = 200;
            };
          };
          history = {
            max_size = 10000;
          };
          color_config = {
            shape_external = "red"; # color of unresolved externals (see 'ansi --list')
            shape_external_resolved = "white"; # color of resolved externals
          };
          cursor_shape = {
            helix_insert = "line";
            helix_normal = "block";
            helix_select = "underscore";
          };
          # better use explore instead instead if below gimmick for pager
          #hooks.display_output = "table -e --width 1000 | less -FSRX";
          #hooks.display_output = "table -e --width 1000 | less -FSR";
          #hooks.display_output = "table -e --width 1000 | less -FS";
          #hooks.display_output = "table -e --width 1000 | less -SRX";
          #hooks.display_output = "table -e --width 1000";
        };

        extraConfig =
          /*
          nu
          */
          ''
            # Custom command to run any command with --help, -h, or man, piping to bat for better readability
            # Usage: h <command> (e.g., h git commit)
            # Old implementation:
            # def --wrapped h [cmd: string, ...args] {
            #   try {
            #     # We append "--help" to the args list so run-external sees it as a parameter,
            #     # not a flag for itself.
            #     run-external $cmd ...($args | append "--help") | bat -l help -P
            #   } catch {
            #     try {
            #       run-external $cmd ...($args | append "-h") | bat -l help -P
            #     } catch {
            #       ^man $cmd | bat -l man -P
            #     }
            #   }
            # }

            def --wrapped h [cmd: string, ...args] {
              let cmd_info = (try { which $cmd } catch { null })
              if $cmd_info == null {
                print $"Command '($cmd)' not found."
                return
              }
              let type = ($cmd_info | get type | first)
              let real_cmd = ($cmd_info | get command | first)

              if $type == "external" {
                try {
                  run-external $real_cmd ...($args | append "--help") | bat -l help
                } catch {
                  try {
                    run-external $real_cmd ...($args | append "-h") | bat -l help
                  } catch {
                    ^man $real_cmd | bat -l man
                  }
                }
              } else {
                # For built-ins, aliases, etc., just run the command with --help
                # to preserve native formatting and colors
                nu -c $"($cmd) --help"
              }
            }

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
                } | table -e --icons
              }
            }

            let carapace_completer = {|place|
              carapace $place.command.0 nushell ...$place.command
              | from json
              | if ($in | default [] | where value =~ '^-.*ERR$' | is-empty) { $in } else { null }
            }

            $env.config.completions.external.completer = $carapace_completer

            $env.config.hooks.pre_prompt ++= [
              { # atuin history to nushell history
                history --clear ; atuin history list --format "{command}\t{directory}" e> /dev/null |
                lines | split column "\t" command cwd | history import
              }
              {
                # Clean up backup files
                try { ^rm -f ~/.config/nushell/history.txt.bak* }
              }
            ]


            #if ('~/.inshellisense/nu/init.nu' | path exists) {
            #  source ~/.inshellisense/nu/init.nu
            #}
            #if "ISTERM" not-in $env and $nu.is-interactive and "VSCODE_RESOLVING_ENVIRONMENT" not-in $env {
            #  #if $nu.is-login {
            #  #  ^${pkgs-unstable.inshellisense}/bin/is -s nu --login
            #  #  exit
            #  #} else {
            #  #  ^${pkgs-unstable.inshellisense}/bin/is -s nu
            #  #  exit
            #  #}
            #  try {
            #    if $nu.is-login {
            #      ^${pkgs-unstable.inshellisense}/bin/is -s nu --login
            #    } else {
            #      ^${pkgs-unstable.inshellisense}/bin/is -s nu
            #    }
            #    exit
            #  } catch {
            #    print ""
            #    print $"(ansi yellow_bold)[Warning](ansi reset) inshellisense failed to start. You are now in a standard nushell."
            #    print "If resources are out of date, you can fix it by running:"
            #    print "  cd ${pkgs-unstable.inshellisense}/lib/node_modules/@microsoft/inshellisense/ ; is reinit"
            #    print ""
            #  }
            #}
            #source "${pkgs-unstable.inshellisense}/lib/node_modules/@microsoft/inshellisense/shell/shellIntegration.nu"
            #''${globalShellInit}

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
          # Carapace bridge: query Fish for tools without native Carapace specs
          $env.CARAPACE_BRIDGES = 'fish'
        '';
      };

    #home.file.".inshellisense/nu/init.nu".text = ''
    #  if "ISTERM" not-in $env and $nu.is-interactive and "VSCODE_RESOLVING_ENVIRONMENT" not-in $env {
    #    if $nu.is-login {
    #      ^${pkgs-unstable.inshellisense}/bin/is -s nu --login
    #      exit
    #    } else {
    #      ^${pkgs-unstable.inshellisense}/bin/is -s nu
    #      exit
    #    }
    #  }
    #'';

    home.packages = [
      pkgs-unstable.glow # for nushell displayoutput hook to highlight markdown
      #pkgs-unstable.inshellisense
    ];
    home.shell.enableNushellIntegration = true;
  };
}
