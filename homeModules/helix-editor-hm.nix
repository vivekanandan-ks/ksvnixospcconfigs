{
  #inputs,
  #config,
  lib,
  #pkgs,
  pkgs-unstable,
  ...
}: {
  programs.helix = {
    enable = true;
    package = pkgs-unstable.helix;
    defaultEditor = true;
    extraPackages = with pkgs-unstable; [
      marksman
      markdown-oxide

      alejandra
      nixd
      nil

      rustfmt
      rust-analyzer

      ruff
      ty

      nufmt

      simple-completion-language-server
      #yaml-language-server
      #systemd-language-server
      #systemd-lsp
      #docker-language-server
      #terraform-lsp
    ];

    languages = {
      language-server.scls = {
        command = "simple-completion-language-server";
        config = {
          feature_words = false; # enable completion by word
          feature_snippets = true; # enable snippets
          snippets_first = true; # completions will return before snippets by default
          snippets_inline_by_word_tail = false; # suggest snippets by WORD tail, for example text `xsq|` become `x^2|` when snippet `sq` has body `^2`
          feature_unicode_input = false; # enable "unicode input"
          feature_paths = false; # enable path completion
          feature_citations = false; # enable citation completion (only on `citation` feature enabled)
        };
      };

      language = [
        {
          name = "nix";
          auto-format = true;
          file-types = ["nix"];
          formatter = {
            command = "alejandra";
            args = ["--quiet"];
          };
          language-servers = ["nixd" "nixl"];
        }

        {
          name = "python";
          auto-format = true;
          file-types = ["py"];
          formatter = {
            command = "ruff";
          };
          language-servers = ["ruff" "ty"];
        }

        {
          name = "rust";
          auto-format = true;
          formatter = {
            command = "rustfmt";
            args = ["--quiet"];
          };
          language-servers = [
            #"scls"
            "rust-analyzer"
          ];
        }

        {
          name = "git-commit";
          language-servers = ["scls"];
        }

        {
          name = "markdown";
          language-servers = ["marksman" "markdown-oxide"];
        }
      ];
    };

    settings = {
      theme = lib.mkForce "my-transparent-theme"; # defined below

      editor = {
        mouse = true; # # mouse support (selection, scrolling, clicking)

        undercurl = true; # squiggly lines in UI

        #line-number = "relative";

        true-color = true; # Force the theme to show colors

        color-modes = true; # necessary for statusline colo changes

        bufferline = "always"; # Show currently open buffers, only when more than one exists.

        /*
        cursorline = true; # Highlight all lines with a cursor

        line-number = "relative"; # Use relative line numbers

        rulers = [120]; # Show a ruler at column 120

        end-of-line-diagnostics = "hint"; # Minimum severity to show a diagnostic after the end of a line

        popup-border = "all";
        */
      };

      editor.file-picker = {
        # Show hidden files in the file picker
        hidden = false;
      };

      editor.end-of-line-diagnostics = "hint";
      editor.inline-diagnostics = {
        cursor-line = "hint"; # Show inline diagnostics when the cursor is on the line
        other-lines = "disable"; # Don't expand diagnostics unless the cursor is on the line
      };

      editor.cursor-shape = {
        insert = "bar";
        normal = "block";
        select = "underline";
      };

      editor.indent-guides = {
        character = "│";
        render = true;
        #skip-levels = 0; # default 0
      };

      editor.auto-save = {
        focus-lost = true; # Save when focus moves away from Helix
        after-delay.enable = true; # Enable saving after a specific time delay
        after-delay.timeout = 3000; # Wait 3000ms (3 seconds) before saving
      };

      editor.lsp = {
        # Disable automatically popups of signature parameter help
        auto-signature-help = true;
        # Show LSP messages in the status line
        display-messages = true;
        # Show hints inline
        display-inlay-hints = true;

        display-progress-messages = true;
      };

      editor.statusline = {
        left = [
          "mode"
          "spinner"
          "version-control"
          "file-name"
          "read-only-indicator"
          "file-modification-indicator"
        ];
        center = [
          #"version-control"
          "file-type"
          "position-percentage"
        ];
        right = [
          "diagnostics"
          "selections"
          "register"
          "position"
          "total-line-numbers"
          "file-encoding"
        ];

        #separator = "|";

        mode = {
          normal = "NORMAL";
          insert = "INSERT";
          select = "SELECT";
        };
      };
    };

    # This defines a new theme called "my-transparent-theme"
    themes = {
      my-transparent-theme = {
        "inherits" = "catppuccin_macchiato"; # Replace "onedark" with your preferred base theme

        # 1. TRANSPARENCY: Setting this to an empty set {} removes the background
        "ui.background" = {};

        # not all theme supports colors for this, so u can manually set the colors like below if ur theme doesn't support it
        # 2. MODE COLORS: Define specific colors for the status bar
        #"ui.statusline.normal" = { fg = "#1e222a"; bg = "#99b6f2ff"; }; # Grey/Blueish
        #"ui.statusline.insert" = { fg = "#1e222a"; bg = "#97da68ff"; }; # Green
        #"ui.statusline.select" = { fg = "#1e222a"; bg = "#bd77d2ff"; }; # Purple
        "ui.statusline" = {bg = "#282c34";};
        "ui.statusline.separator" = {
          fg = "#16161e";
          bg = "#00000000";
        };

        "ui.virtual.indent-guide" = {fg = "#61697bff";};

        # 3. Gutter/Line Number Transparency (ADD THESE)
        # We use #00000000 to set the background to fully transparent
        #"ui.gutter" = { bg = "#00000000"; };
        "ui.gutter" = {};
        #"ui.linenr" = { fg = "#abb2bf"; bg = "#00000000"; };
        #"ui.linenr.selected" = { fg = "#c678dd"; bg = "#00000000"; modifiers = ["bold"]; };
      };
    };
  };
}
