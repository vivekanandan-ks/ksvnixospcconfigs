{...}: {
  programs.helix = {
    enable = true;
    defaultEditor = true;

    languages = {
      language-server = {
        just-lsp = {
          command = "just-lsp";
        };

        luau-lsp = {
          command = "luau-lsp analyze";
        };
      };

      language = [
        {
          name = "just";
          language-servers = ["just-lsp"];
        }

        {
          name = "luau";
          language-servers = ["luau-lsp"];
          scope = "scope.luau";
          file-types = ["luau"];
          comment-tokens = "--";
          indent = {
            tab-width = 4;
            unit = "    ";
          };
        }

        {
          name = "nix";
          auto-format = true;
          formatter = {
            command = "alejandra";
            args = ["--quiet"];
          };
        }
      ];
    };

    settings = {
      theme = "ao";

      editor = {
        # Show currently open buffers, only when more than one exists.
        bufferline = "multiple";
        # Highlight all lines with a cursor
        cursorline = true;
        # Use relative line numbers
        line-number = "relative";
        # Show a ruler at column 120
        rulers = [120];
        # Force the theme to show colors
        true-color = true;
        # Minimum severity to show a diagnostic after the end of a line
        end-of-line-diagnostics = "hint";
        popup-border = "all";
      };

      editor.inline-diagnostics = {
        cursor-line = "error"; # Show inline diagnostics when the cursor is on the line
        other-lines = "disable"; # Don't expand diagnostics unless the cursor is on the line
      };

      editor.cursor-shape = {
        insert = "bar";
        normal = "block";
        select = "underline";
      };

      editor.indent-guides = {
        character = "╎";
        render = true;
      };

      editor.lsp = {
        # Disable automatically popups of signature parameter help
        auto-signature-help = false;
        # Show LSP messages in the status line
        display-messages = true;
        # Show hints inline
        display-inlay-hints = true;
      };

      editor.file-picker = {
        # Show hidden files in the file picker
        hidden = false;
      };

      editor.statusline = {
        # left = ["mode" "spinner" "version-control" "file-name"];
        center = ["version-control" "file-type" "position-percentage"];
        right = ["diagnostics" "selections" "register" "position" "total-line-numbers" "file-encoding"];
      };

      keys.normal = {
        "A-," = "goto_previous_buffer";
        "A-." = "goto_next_buffer";
        "A-q" = ":buffer-close";
        "A-/" = "repeat_last_motion";
        A-x = "extend_to_line_bounds";
        X = "select_line_above";
      };

      keys.select = {
        A-x = "extend_to_line_bounds";
        X = "select_line_above";
      };
    };
  };
}
