{
  inputs,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  #importing the nvf module
  imports = [
    inputs.nvf.homeManagerModules.default
  ];

  # nvf
  programs.nvf =
    let
      isMaximal = false;
    in
    {
      enable = true;


      # your settings need to go into the settings attribute set
      # most settings are documented in the appendix
      #the default settings can also be seen here: https://github.com/NotAShelf/nvf/blob/main/configuration.nix
      settings = {
        vim = {
          #package = pkgs-unstable.neovim-unwrapped;
          package = pkgs.neovim-unwrapped;
          viAlias = false; # changed
          vimAlias = false; # changed
          debugMode = {
            enable = false;
            level = 16;
            logFile = "/tmp/nvim.log";
          };

          spellcheck = {
            enable = true;
            #programmingWordlist.enable = true; # maximal
          };

          lsp = {
            # This must be enabled for the language modules to hook into
            # the LSP API.
            enable = true;

            formatOnSave = true;
            lspkind.enable = true; # changed
            lightbulb.enable = true;
            lspsaga.enable = true; # changed
            trouble.enable = true;
            lspSignature.enable = false; # not maximal # conflicts with blink in maximal
            otter-nvim.enable = true; # maximal
            nvim-docs-view.enable = true; # maximal
          };

          debugger = {
            nvim-dap = {
              enable = true;
              ui.enable = true;
            };
          };

          # This section does not include a comprehensive list of available language modules.
          # To list all available language module options, please visit the nvf manual.
          languages = {
            enableFormat = true;
            enableTreesitter = true;
            enableExtraDiagnostics = true;

            # Languages that will be supported in default and maximal configurations.
            nix.enable = true;
            markdown.enable = true;

            # Languages that are enabled in the maximal configuration.
            bash.enable = true; # changed
            clang.enable = isMaximal;
            css.enable = isMaximal;
            html.enable = true; # changed
            sql.enable = true; # changed
            java.enable = isMaximal;
            kotlin.enable = isMaximal;
            ts.enable = isMaximal;
            go.enable = isMaximal;
            lua.enable = isMaximal;
            zig.enable = isMaximal;
            python.enable = true; # changed
            typst.enable = isMaximal;
            rust = {
              enable = isMaximal;
              crates.enable = isMaximal;
            };

            # Language modules that are not as common.
            assembly.enable = false;
            astro.enable = false;
            nu.enable = true; # changed
            csharp.enable = false;
            julia.enable = false;
            vala.enable = false;
            scala.enable = false;
            r.enable = false;
            gleam.enable = false;
            dart.enable = false;
            ocaml.enable = false;
            elixir.enable = false;
            haskell.enable = false;
            ruby.enable = false;
            fsharp.enable = false;

            tailwind.enable = false;
            svelte.enable = false;

            # Nim LSP is broken on Darwin and therefore
            # should be disabled by default. Users may still enable
            # `vim.languages.vim` to enable it, this does not restrict
            # that.
            # See: <https://github.com/PMunch/nimlsp/issues/178#issue-2128106096>
            nim.enable = false;
          };

          visuals = {
            nvim-scrollbar.enable = true; # maximal
            nvim-web-devicons.enable = true;
            nvim-cursorline.enable = true;
            cinnamon-nvim.enable = true;
            fidget-nvim.enable = true;

            highlight-undo.enable = true;
            indent-blankline.enable = true;

            # Fun
            cellular-automaton.enable = false;
          };

          statusline = {
            lualine = {
              enable = true;
              theme = "catppuccin";
            };
          };

          theme = {
            enable = true;
            name = "catppuccin";
            style = "mocha";
            transparent = true; # changed
          };

          autopairs.nvim-autopairs.enable = true;

          # nvf provides various autocomplete options. The tried and tested nvim-cmp
          # is enabled in default package, because it does not trigger a build. We
          # enable blink-cmp in maximal because it needs to build its rust fuzzy
          # matcher library.
          autocomplete = {
            nvim-cmp.enable = false; # not maximal
            blink-cmp.enable = true; # maximal # modern rust implementation (preferred)
          };

          snippets.luasnip.enable = true;

          filetree = {
            neo-tree = {
              enable = true;
            };
          };

          tabline = {
            nvimBufferline.enable = true;
          };

          treesitter.context.enable = true;

          binds = {
            whichKey.enable = true;
            cheatsheet.enable = true;
            hardtime-nvim = {
              enable = true;
              setupOpts = {
                restriction_mode = "hint"; #other opyions: "block"
                disable_mouse = false;
              };

            };
          };

          telescope.enable = true;

          git = {
            enable = true;
            gitsigns.enable = true;
            gitsigns.codeActions.enable = false; # throws an annoying debug message
            neogit.enable = isMaximal;
          };

          minimap = {
            minimap-vim.enable = true; # changed
            codewindow.enable = true; # maximal # lighter, faster, and uses lua for configuration
          };

          dashboard = {
            #dashboard-nvim.enable = true; # changed
            #alpha.enable = true; # maximal
          };

          notify = {
            nvim-notify.enable = true;
          };

          projects = {
            project-nvim.enable = true; # maximal
          };

          utility = {
            ccc.enable = false;
            vim-wakatime.enable = true; # changed
            diffview-nvim.enable = true;
            yanky-nvim.enable = false;
            icon-picker.enable = isMaximal;
            surround.enable = true; # maximal
            leetcode-nvim.enable = isMaximal;
            multicursors.enable = true; # maximal
            smart-splits.enable = true; # maximal
            undotree.enable = true; # maximal
            nvim-biscuits.enable = true; # maximal

            motion = {
              hop.enable = true;
              leap.enable = true;
              precognition.enable = true; # maximal
              #flash-nvim.enable = true; # extra
            };
            images = {
              image-nvim.enable = true; # changed
              img-clip.enable = true; # maximal
            }; # added this app for this to work properly : ueberzugpp
          };

          notes = {
            obsidian.enable = false; # FIXME: neovim fails to build if obsidian is enabled
            neorg.enable = false;
            orgmode.enable = false;
            mind-nvim.enable = isMaximal;
            todo-comments.enable = true;
          };

          terminal = {
            toggleterm = {
              enable = true;
              lazygit.enable = true;
            };
          };

          ui = {
            borders.enable = true;
            noice.enable = true;
            colorizer.enable = true;
            modes-nvim.enable = false; # the theme looks terrible with catppuccin
            illuminate.enable = true; # default false
            breadcrumbs = {
              enable = true; # maximal
              navbuddy.enable = true; # maximal
            };
            smartcolumn = {
              enable = true;
              setupOpts.custom_colorcolumn = {
                # this is a freeform module, it's `buftype = int;` for configuring column position
                nix = "110";
                ruby = "120";
                java = "130";
                go = [
                  "90"
                  "130"
                ];
              };
            };
            fastaction.enable = true;
          };

          assistant = {
            chatgpt.enable = false;
            copilot = {
              enable = false;
              cmp.enable = isMaximal;
            };
            codecompanion-nvim.enable = false;
            avante-nvim.enable = isMaximal;
          };

          session = {
            nvim-session-manager.enable = false;
          };

          gestures = {
            gesture-nvim.enable = false;
          };

          comments = {
            comment-nvim.enable = true;
          };

          presence = {
            neocord.enable = false;
          };
        };
      };
    };
  
  home.packages = with pkgs-unstable;[
    ueberzugpp
  ];

}
