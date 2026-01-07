{
  inputs,
  pkgs,
  pkgs-unstable,
  nix4vscode,
  system,
  username,
  ...
}:
let

  pkgs-vscode = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
    overlays = [
      nix4vscode.overlays.default
    ];
  };

  vscode-package = pkgs-unstable.vscode-fhs;
  vscode-extnsns =
    (pkgs-vscode.nix4vscode.forVscode [

      "ms-python.python" # Python
      "ms-python.debugpy" # Python Debugger
      "KevinRose.vsc-python-indent" # Python Indent

      "jnoortheen.nix-ide" # Nix IDE
      "tamasfe.even-better-toml" # Even Better TOML
      "mads-hartmann.bash-ide-vscode" # Bash IDE
      "redhat.vscode-yaml" # YAML
      "thenuprojectcontributors.vscode-nushell-lang" # vscode-nushell-lang

      "eamodio.gitlens" # GitLens
      "wakatime.vscode-wakatime" # https://wakatime.com/

      "rust-lang.rust-analyzer" # rust-analyzer

    ])
    ++ (with pkgs-unstable.vscode-extensions; [
      # nix
      #jnoortheen.nix-ide # Nix IDE
      #brettm12345.nixfmt-vscode # nixfmt (not needed since we use nix IDE for formatting too)

      #tamasfe.even-better-toml # Even Better TOML
      #mads-hartmann.bash-ide-vscode # Bash IDE
      #redhat.vscode-yaml # YAML

      # Python
      #ms-python.python # Python
      #ms-python.debugpy # Python Debugger

      #thenuprojectcontributors.vscode-nushell-lang # vscode-nushell-lang
      #eamodio.gitlens # GitLens

      #wakatime.vscode-wakatime # https://wakatime.com/

    ])
    ++ (with pkgs.vscode-extensions; [

      # Python
      #ms-python.python # Python
      #ms-python.debugpy # Python Debugger
    ])
    ++ (pkgs-unstable.vscode-utils.extensionsFromVscodeMarketplace [

      /*
        {
          # Python Indent https://marketplace.visualstudio.com/items?itemName=KevinRose.vsc-python-indent&ssr=true
          name = "vsc-python-indent";
          publisher = "kevinrose";
          version = "1.21.0";
          sha256 = "1zlkbxgl8bad8g1lm60z0zf5gr1011p696zps3azr89cdxa63wja";
        }
      */
      /*
        {
          name = "remote-ssh-edit";
          publisher = "ms-vscode-remote";
          version = "0.47.2";
          sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
        }
      */
    ]);
in
{
  home.packages = with pkgs-unstable; [

    #nixfmt
    alejandra
    nixd
    #nil

    # vscode
    /*
      (vscode-with-extensions.override {

        vscode = vscode-package;

        vscodeExtensions = vscode-extnsns;
      })
    */
  ];

  # vscode
  # https://unix.stackexchange.com/questions/768678/configure-vscode-in-nixos
  # https://discourse.nixos.org/t/home-manager-vscode-extension-settings-mutableextensionsdir-false/33878
  programs.vscode = {
    enable = true;
    package = vscode-package;
    mutableExtensionsDir = false;

    profiles.default = {
      extensions = vscode-extnsns;
      enableExtensionUpdateCheck = false;
      enableUpdateCheck = false;
      enableMcpIntegration = true; # mcp servers declared in mcp-hm.nix

      userSettings = {
        ##### VsCode Settings #####
        ## Commonly Used
        "files.autoSave" = "afterDelay";
        "git.openRepositoryInParentFolders" = "always";

        #### NixIDE
        "nix.enableLanguageServer" = true;
        "nix.formatterPath" = "alejandra";
        "nix.serverPath" = "nixd";
        "nix.serverSettings" = {
          "nixd" = {
            "eval" = { };
            "formatting" = {
              "command" = "alejandra";
              #nixd and alejandra to be added as packages
            };
            "options" = {
              "enable" = true;
              "target" = {
                "args" = [ ];
                ## NixOS options
                # "installable" = "<flakeref>#nixosConfigurations.ksvnixospc.options";
                "installable" = "${./../flake.nix}#nixosConfigurations.${username}.options";
                ## Flake-parts options
                # "installable" = "<flakeref>#debug.options";
                ## Home-manager options
                #"installable" = "~/Documents/ksvnixospcconfigs/home.nix#homeConfigurations.ksvnixospc.options";
                #"installable" = "${./..}#homeConfigurations.ksvnixospc.options";
              };
            };
          };
        };
        "[nix]" = {
          "editor.defaultFormatter" = "jnoortheen.nix-ide";
        };
        "update.mode" = "none";
      };

    };

  };

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # To use VS Code and other apps under Wayland
  };

}
