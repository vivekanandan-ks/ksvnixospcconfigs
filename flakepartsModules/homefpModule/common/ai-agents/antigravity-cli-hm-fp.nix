{...}: {
  flake.homeModules.common = {
    antigravity-cli = {
      pkgs-unstable,
      ...
    }: {
      programs.antigravity-cli = {
        enable = true;
        package = pkgs-unstable.antigravity-cli;
        defaultModel = "gemini-3.1-pro-preview";
        enableMcpIntegration = true;

        context = {
          GEMINI = ./GEMINI.md;
          CONTEXT = ./CONTEXT.md;
        };

        settings = {
          context.fileName = [ "GEMINI.md" "CONTEXT.md" ];
        };
      };
    };
  };
}
