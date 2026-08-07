_: {
  flake.homeModules.nonDroid.vscode-code = {
    config,
    pkgs-unstable,
    ...
  }: {
    # vscode
    # https://unix.stackexchange.com/questions/768678/configure-vscode-in-nixos
    # https://discourse.nixos.org/t/home-manager-vscode-extension-settings-mutableextensionsdir-false/33878
    programs.vscode = {
      enable = true;
      package = pkgs-unstable.vscode-fhs;
      mutableExtensionsDir = false;

      profiles.default = {
        extensions = config.myEditor.vscode.extensions;
        enableExtensionUpdateCheck = false;
        enableUpdateCheck = false;
        enableMcpIntegration = true; # mcp servers declared in mcp-hm.nix
        userSettings = config.myEditor.vscode.userSettings;
      };
    };
  };
}
