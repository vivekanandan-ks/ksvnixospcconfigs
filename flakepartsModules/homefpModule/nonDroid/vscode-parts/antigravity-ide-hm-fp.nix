{self, ...}: {
  flake.homeModules.nonDroid.antigravity-ide = {
    config,
    lib,
    pkgs-unstable,
    ...
  }: {
    programs.antigravity = {
      enable = true;
      package = pkgs-unstable.antigravity-ide-fhs;
      mutableExtensionsDir = false;

      argvSettings = {
        "enable-crash-reporter" = false;
        "password-store" = "basic";
      };

      profiles.default = {
        extensions = config.myEditor.vscode.extensions;
        enableMcpIntegration = true;

        enableExtensionUpdateCheck = false;
        enableUpdateCheck = false;

        userSettings =
          config.myEditor.vscode.userSettings
          // {
            "antigravity.autocomplete.enable" = true;
            "antigravity.autocomplete.acceptMode" = "full";
            "antigravity.agent.planningMode" = "always";
            "antigravity.agent.autoFixErrors" = true;
            "antigravity.agent.toolPermission" = "always-proceed";

            "antigravity.agent.rulesFiles" = [
              "${self.aiContext.GEMINI}"
              "${self.aiContext.CONTEXT}"
            ];
          };
      };
    };

    # Bridge directory names so Antigravity IDE reads the Home Manager paths:
    home.file.".antigravity-ide".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.antigravity";

    xdg.configFile."Antigravity IDE".source =
      config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/Antigravity";
  };
}
