{self, ...}: {
  flake.homeModules.nonDroid.antigravity-ide = {
    config,
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

    # Pure in-store links to bridge Home Manager directory names to Antigravity IDE
    home.file.".antigravity-ide/extensions".source =
      config.home.file.".antigravity/extensions".source;

    home.file.".antigravity-ide/argv.json".source =
      config.home.file.".antigravity/argv.json".source;

    xdg.configFile."Antigravity IDE/User/settings.json".source =
      config.xdg.configFile."Antigravity/User/settings.json".source;

    xdg.configFile."Antigravity IDE/User/mcp.json".source =
      config.xdg.configFile."Antigravity/User/mcp.json".source;
  };
}
