{
  #inputs,
  #config,
  #lib,
  #pkgs,
  pkgs-unstable,
  ...
}:

{

  programs.zed-editor = {
    enable = true;
    package = pkgs-unstable.zed-editor;
    extensions = [
      # get the names from here : https://zed.dev/extensions
      "nix"
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

    ];
    extraPackages = with pkgs-unstable; [
      nixd
      nil
    ];
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

    /*
      userSettings = {
        features = {
          copilot = false;
        };
        telemetry = {
          metrics = false;
        };
        vim_mode = false;
        ui_font_size = 16;
        buffer_font_size = 16;

      };
    */

    /*
      userTasks = [
        {
          label = "Format Code";
          command = "nix";
          args = [
            "fmt"
            "$ZED_WORKTREE_ROOT"
          ];
        }
      ];
    */

  };

}
