{...}: {
  flake.homeModules.common.mcp = {
    #inputs,
    #config,
    lib,
    #pkgs,
    pkgs-unstable,
    ...
  }: {
    programs.mcp = {
      enable = true;
      servers = {
        nixos = {
          # https://mcp-nixos.io/usage
          command = lib.getExe pkgs-unstable.mcp-nixos;
          args = [];
        };

        git = {
          command = lib.getExe pkgs-unstable.mcp-server-git;
          args = [];
        };

        memory = {
          command = lib.getExe pkgs-unstable.mcp-server-memory;
          args = [];
        };

        sequential-thinking = {
          command = lib.getExe pkgs-unstable.mcp-server-sequential-thinking;
          args = [];
        };

        fetch = {
          command = lib.getExe pkgs-unstable.mcp-server-fetch;
          args = [];
        };

        github = {
          command = lib.getExe pkgs-unstable.github-mcp-server;
          args = [];
        };
      };
    };
  };
}
