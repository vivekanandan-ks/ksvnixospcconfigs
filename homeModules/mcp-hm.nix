{
  #inputs,
  #config,
  #lib,
  #pkgs,
  #pkgs-unstable,
  ...
}:

{
  programs.mcp = {
    enable = true;
    servers = {

      nixos = {
        # https://mcp-nixos.io/usage
        command = "nix";
        args = [
          "run"
          "github:utensils/mcp-nixos"
          "--"
        ];
      };

      git = {
        # https://github.com/modelcontextprotocol/servers/tree/main/src/git
        command = "uvx";
        args = [ "mcp-server-git" ];
      };

      memory = {
        # https://github.com/modelcontextprotocol/servers/tree/main/src/memory
        command = "npx";
        args = [
          "-y"
          "@modelcontextprotocol/server-memory"
        ];
      };

      sequential-thinking = {
        # https://github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking
        command = "npx";
        args = [
          "-y"
          "@modelcontextprotocol/server-sequential-thinking"
        ];
      };

    };
  };

}
