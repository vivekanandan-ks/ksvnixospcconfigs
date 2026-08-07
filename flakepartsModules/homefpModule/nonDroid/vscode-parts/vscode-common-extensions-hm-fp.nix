{lib, ...}: {
  flake-file.inputs = {
    # for vscode extensions
    nix4vscode = {
      url = "github:nix-community/nix4vscode";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.homeModules.nonDroid.vscode-common-extensions = {
    inputs,
    pkgs-unstable,
    system,
    ...
  }: let
    pkgs-vscode = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        inputs.nix4vscode.overlays.default
      ];
    };
  in {
    options.myEditor.vscode.extensions = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default =
        (pkgs-vscode.nix4vscode.forVscode [
          #"ms-python.python" # Python
          #"ms-python.debugpy" # Python Debugger
          #"KevinRose.vsc-python-indent" # Python Indent

          "jnoortheen.nix-ide" # Nix IDE
          "tamasfe.even-better-toml" # Even Better TOML
          "mads-hartmann.bash-ide-vscode" # Bash IDE
          "redhat.vscode-yaml" # YAML
          "thenuprojectcontributors.vscode-nushell-lang" # vscode-nushell-lang

          #"eamodio.gitlens" # GitLens
          #"wakatime.vscode-wakatime" # https://wakatime.com/

          #"rust-lang.rust-analyzer" # rust-analyzer
        ])
        ++ (with pkgs-unstable.vscode-extensions; [
          # nix
          #jnoortheen.nix-ide # Nix IDE
          #brettm12345.nixfmt-vscode # nixfmt (not needed since we use nix IDE for formatting too)

          #tamasfe.even-better-toml # Even Better TOML
          #mads-hartmann.bash-ide-vscode # Bash IDE
          #redhat.vscode-yaml # YAML

          # Python
          ms-python.python # Python
          ms-python.debugpy # Python Debugger

          #thenuprojectcontributors.vscode-nushell-lang # vscode-nushell-lang
          eamodio.gitlens # GitLens

          #wakatime.vscode-wakatime # https://wakatime.com/

          rust-lang.rust-analyzer

          catppuccin.catppuccin-vsc
          catppuccin.catppuccin-vsc-icons
          enkia.tokyo-night
          sdras.night-owl
          silofy.hackthebox

          justusadam.language-haskell
          haskell.haskell

          visualjj.visualjj # visualjj.com
        ])
        ++
        /*
          (with pkgs.vscode-extensions; [
            # Python
            #ms-python.python # Python
            #ms-python.debugpy # Python Debugger
          ])
        ++
        */
        (pkgs-unstable.vscode-utils.extensionsFromVscodeMarketplace [
          {
            # Python Indent https://marketplace.visualstudio.com/items?itemName=KevinRose.vsc-python-indent&ssr=true
            name = "vsc-python-indent";
            publisher = "kevinrose";
            version = "1.21.0";
            sha256 = "1zlkbxgl8bad8g1lm60z0zf5gr1011p696zps3azr89cdxa63wja";
          }
          /*
          {
            name = "remote-ssh-edit";
            publisher = "ms-vscode-remote";
            version = "0.47.2";
            sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
          }
          */
        ]);
    };
  };
}
