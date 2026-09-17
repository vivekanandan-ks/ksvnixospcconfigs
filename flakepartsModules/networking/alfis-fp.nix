_: {
  flake.nixosModules.alfis = {
    config,
    lib,
    pkgs-unstable,
    ...
  }: let
    alfisConfig = (pkgs-unstable.formats.toml { }).generate "alfis.toml" {
      # Genesis block hash of the Alfis blockchain (mandatory for consensus)
      origin = "0000001D2A77D63477172678502E51DE7F346061FF7EB188A2445ECA3FC0780E";

      net = {
        peers = [
          "peer-v4.alfis.name:4244"
          "peer-v6.alfis.name:4244"
          "peer-ygg.alfis.name:4244"
        ];
        listen = "[::]:4244";
        public = true;
        yggdrasil_only = false;
      };

      dns = {
        listen = "127.0.0.1:5335";
        threads = 4;
        cache_memory_limit_mb = 100;
        forwarders = ["1.1.1.1:53"];
        bootstraps = ["9.9.9.9:53"];
      };

      mining = {
        threads = 0;
        lower = true;
      };
    };
  in {
    # Desktop GUI app available in app launcher
    environment.systemPackages = [
      pkgs-unstable.alfis
    ];

    # Headless 24/7 background DNS resolver
    systemd.services.alfis = {
      description = "Alfis Decentralized DNS Daemon";
      after = [ "network.target" "yggdrasil.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${pkgs-unstable.alfis}/bin/alfis -n -c ${alfisConfig}";
        StateDirectory = "alfis";
        WorkingDirectory = "/var/lib/alfis";
        Restart = "always";
        RestartSec = "5s";
        CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
      };
    };

    # Split DNS: Only route .ygg and .anon to Alfis on 127.0.0.1:5335
    services.resolved = {
      enable = true;
      settings.Resolve = {
        DNS = "127.0.0.1:5335";
        Domains = [ "~ygg" "~anon" ];
      };
    };
  };
}
