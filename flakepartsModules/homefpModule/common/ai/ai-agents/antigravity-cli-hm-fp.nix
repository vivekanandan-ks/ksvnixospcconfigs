{self, ...}: {
  flake.aiContext = {
    GEMINI = ./GEMINI.md;
    CONTEXT = ./CONTEXT.md;
  };

  flake.homeModules.common = {
    antigravity-cli = {
      lib,
      pkgs-unstable,
      ...
    }: {
      home.sessionVariables = {
        # Limit libuv worker threads to prevent background agent from saturating all CPU cores (2C/4T)
        UV_THREADPOOL_SIZE = "2";
      };

      programs.antigravity-cli = {
        enable = true;
        package = pkgs-unstable.antigravity-cli;
        defaultModel = "gemini-3.6-flash";
        enableMcpIntegration = true;

        # Automatically pass all context contributions across the dendritic tree
        context = self.aiContext;

        settings = {
          toolPermission = "always-proceed";
          # Automatically discover all context filenames without hardcoding
          context.fileName = lib.mapAttrsToList (_name: path: baseNameOf (toString path)) self.aiContext;
        };
      };
    };
  };
}
