{self, ...}: {
  flake.homeModules.nonDroid.antigravity-ide = {
    config,
    pkgs-unstable,
    ...
  }: let
    wrappedAntigravity = pkgs-unstable.symlinkJoin {
      name = "antigravity-ide-wrapped";
      paths = [pkgs-unstable.antigravity-ide-fhs];
      buildInputs = [pkgs-unstable.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/antigravity-ide \
          --add-flags "--extensions-dir ~/.antigravity/extensions --user-data-dir ~/.config/Antigravity"
      '';
    };
  in {
    programs.antigravity = {
      enable = true;
      package = wrappedAntigravity;
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
  };
}
