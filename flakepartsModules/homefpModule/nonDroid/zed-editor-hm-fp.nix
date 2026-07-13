{...}: {
  flake.homeModules.nonDroid.zed-editor = {
    #inputs,
    #config,
    #lib,
    pkgs,
    pkgs-unstable,
    ...
  }: {
    programs.zed-editor = {
      enable = true;
      package = pkgs.zed-editor;
      extensions = [
        # get the names from here : https://zed.dev/extensions
        "nix"
        "haskell" # https://zed.dev/extensions/haskell
        "html"
        "nu"
        "yaml"
        "basher"
        "toml"
        "git-firefly"
        "github-actions"
        "mcp-server-github"
        "github-activity-summarizer"
        "opencode"
        "quadlet"
        "dockerfile"
        "docker-compose"
        "catppuccin"
        "catppuccin-icons"
        "terraform"
        "catppuccin-blur"
        "ruff"
        "csv"
        "vscode-dark-modern"
        "intellij-newui-theme"
        "python-requirements"
        "fish"
        "nginx"
        "wakatime"
        "helm"
        "python-snippets"
        "caddyfile"
        "http"
        "perplexity"
        "strace"
        #"cython"
        "color-highlight"
        "supaglass"
        "opentofu"
        "jq"
        "django"
        "eyecandy"
        "gemini"
      ];

      extraPackages = with pkgs-unstable; [
        nixd
        nil
        alejandra
      ];

      enableMcpIntegration = true;
      #installRemoteServer = false; # default false
      #mutableUserDebug = true; # default true
      #mutableUserTasks = true; # default true
      /*
      userKeymaps = [
        # default []
        {
          context = "Workspace";
          bindings = {
            ctrl-shift-t = "workspace::NewTerminal";
          };
        }

      ];
      */

      userSettings = {
        #helix_mode = true;
        indent_guides = {
          background_coloring = "disabled";
          coloring = "indent_aware";
        };
        sticky_scroll = {
          enabled = true;
        };
        which_key = {
          enabled = true;
        };
        autosave = "on_focus_change";
        auto_install_extensions = {
          basher = true;
          caddyfile = true;
          catppuccin = true;
          "catppuccin-blur" = true;
          "catppuccin-icons" = true;
          "color-highlight" = true;
          csv = true;
          django = true;
          "docker-compose" = true;
          dockerfile = true;
          eyecandy = true;
          fish = true;
          "git-firefly" = true;
          "github-actions" = true;
          "github-activity-summarizer" = true;
          helm = true;
          html = true;
          http = true;
          "intellij-newui-theme" = true;
          jq = true;
          "mcp-server-github" = true;
          nginx = true;
          nix = true;
          nu = true;
          opencode = true;
          opentofu = true;
          perplexity = true;
          "python-requirements" = true;
          "python-snippets" = true;
          quadlet = true;
          ruff = true;
          strace = true;
          supaglass = true;
          terraform = true;
          toml = true;
          "vscode-dark-modern" = true;
          wakatime = true;
          yaml = true;
          gemini = true;
          haskell = true;
        };
        buffer_font_family = "DejaVu Sans Mono";
        buffer_font_size = 14.666666666666666;
        theme = "Catppuccin Mocha";
        ui_font_family = "DejaVu Sans";
        ui_font_size = 13.333333333333334;
        languages = {
          Nix = {
            formatter = {
              external = {
                command = "alejandra";
                arguments = ["--quiet"];
              };
            };
          };
        };
        context_servers = {
          git = {
            args = [];
            command = "/nix/store/pmifki14h7xvawrc8zcwyh232bqhblbw-mcp-server-git-2026.6.16/bin/mcp-server-git";
          };
          memory = {
            args = [];
            command = "/nix/store/kfjjh8ls6cippmg3f53wfg6hn2vacvbl-mcp-server-memory-2026.1.26/bin/mcp-server-memory";
          };
          nixos = {
            args = [];
            command = "/nix/store/1ir5mdy5a8k1mvydmkm607l9b9x0acfw-mcp-nixos-2.4.3/bin/mcp-nixos";
          };
          "sequential-thinking" = {
            args = [];
            command = "/nix/store/igpblzb777l3rr3vcxjkx95zsnij1lnc-mcp-server-sequential-thinking-2026.1.26/bin/mcp-server-sequential-thinking";
          };
          fetch = {
            args = [];
            command = "/nix/store/3ayls7mjqd3238mibn274sishh0v1k4v-mcp-server-fetch-2026.6.16/bin/mcp-server-fetch";
          };
          github = {
            args = [];
            command = "/nix/store/kd0jkxgkqa600kby1v5px5f6fpb3qz5l-github-mcp-server-1.5.0/bin/github-mcp-server";
          };
        };
      };
    };
  };
}
