_: {
  flake.homeModules.common = {
    antigravity-cli = {pkgs-unstable, ...}: {
      programs.antigravity-cli = {
        enable = true;
        package = pkgs-unstable.antigravity-cli;
        defaultModel = "gemini-3.6-flash";
        enableMcpIntegration = true;

        context = {
          GEMINI = ./GEMINI.md;
          CONTEXT = ./CONTEXT.md;
        };

        settings = {
          toolPermission = "always-proceed";
          context.fileName = ["GEMINI.md" "CONTEXT.md"];
        };
      };
    };
  };
}
