{ lib, ... }: {
  flake.nixosModules.localAliases = { lib, ... }: {
    options.localAliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.port;
      default = { };
      description = "Mapping of .local domain aliases to localhost ports.";
      example = {
        "jellyfin.local" = 8096;
        "navidrome.local" = 4533;
      };
    };
  };
}
