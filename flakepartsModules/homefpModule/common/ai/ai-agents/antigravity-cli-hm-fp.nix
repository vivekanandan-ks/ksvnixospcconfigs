{self, ...}: {
  flake.aiContext = {
    GEMINI = ./GEMINI.md;
    CONTEXT = ./CONTEXT.md;
  };

  flake.homeModules.common = {
    antigravity-cli = {pkgs-unstable, ...}: {
      programs.antigravity-cli = {
        enable = true;
        package = pkgs-unstable.antigravity-cli;
        defaultModel = "gemini-3.6-flash";
        enableMcpIntegration = true;

        context = {
          GEMINI = self.aiContext.GEMINI;
          CONTEXT = self.aiContext.CONTEXT;
        };

        settings = {
          toolPermission = "always-proceed";
          context.fileName = [
            (baseNameOf self.aiContext.GEMINI)
            (baseNameOf self.aiContext.CONTEXT)
          ];
        };
      };
    };
  };
}
