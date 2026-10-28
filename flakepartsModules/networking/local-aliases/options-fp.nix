_: {
  flake.nixosModules.localServices = {lib, ...}: {
    options.localServicesPorts = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf lib.types.port);
      default = {};
      description = "Mapping of service names to port configurations ({ proxyPort, listenPort ? proxyPort + 10000 }).";
      example = {
        navidrome = { proxyPort = 4533; };
        komga = { proxyPort = 25600; listenPort = 25601; };
      };
    };
  };
}
