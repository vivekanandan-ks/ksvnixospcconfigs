_: {
  flake.nixosModules.localServices = {lib, ...}: {
    options.localServicesPorts = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = {};
      description = "Mapping of service names to port configurations and metadata ({ proxyPort, listenPort?, title?, category?, role? }).";
      example = {
        navidrome = { proxyPort = 4533; category = "Music"; role = "user"; };
        sonarr = { proxyPort = 8989; category = "Automation"; role = "admin"; };
      };
    };
  };
}
