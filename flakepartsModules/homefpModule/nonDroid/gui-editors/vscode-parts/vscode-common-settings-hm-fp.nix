{lib, ...}: {
  flake.homeModules.nonDroid.vscode-common-settings = _: {
    options.myEditor.vscode.userSettings = lib.mkOption {
      type = lib.types.attrs;
      default = {
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
            "eval" = {};
            "formatting" = {
              "command" = ["alejandra"];
              #nixd and alejandra to be added as packages
            };
            "options" = {
              "nixos" = {
                "expr" = "(builtins.getFlake \"\${./../../../flake.nix}\").nixosConfigurations.\${username}.options";
              };
              # "enable" = true;
              # "target" = {
              #   "args" = [];
              #   ## NixOS options
              #   # "installable" = "<flakeref>#nixosConfigurations.ksvnixospc.options";
              #   "installable" = "\${./../../../flake.nix}#nixosConfigurations.\${username}.options";
              #   ## Flake-parts options
              #   # "installable" = "<flakeref>#debug.options";
              #   ## Home-manager options
              #   #"installable" = "~/Documents/ksvnixospcconfigs/home.nix#homeConfigurations.ksvnixospc.options";
              #   #"installable" = "\${./..}#homeConfigurations.ksvnixospc.options";
              # };
            };
          };
        };
        "[nix]" = {
          "editor.defaultFormatter" = "jnoortheen.nix-ide";
        };
        "update.mode" = "none";
        "workbench.colorTheme" = "Catppuccin Mocha";
      };
    };
  };
}
