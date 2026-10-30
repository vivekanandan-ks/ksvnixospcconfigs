_: {
  flake.nixosModules.localServices = {
    config,
    lib,
    ...
  }: let
    rawCfg = config.localServicesPorts;
    hasServices = rawCfg != {};

    # Resolves listenPort to (proxyPort + 10000) unless explicitly overridden
    services = lib.mapAttrs (_: p: {
      proxyPort = p.proxyPort;
      listenPort = p.listenPort or (p.proxyPort + 10000);
    }) rawCfg;

    listenPorts = map (s: s.listenPort) (builtins.attrValues services);
  in {
    config = lib.mkIf hasServices {
      services.caddy = {
        enable = true;
        # Slowloris defense: drop stalled connections while keeping large uploads safe
        globalConfig = ''
          servers {
            timeouts {
              read_header 10s
              idle 2m
            }
          }
        '';
        virtualHosts =
          lib.mapAttrs' (
            name: { proxyPort, listenPort }:
              lib.nameValuePair "https://:${toString listenPort}" {
                extraConfig = ''
                  # ${name} HTTPS reverse proxy
                  tls internal {
                    protocols tls1.3
                  }

                  ${config.localServicesSecuritySnippet}

                  reverse_proxy 127.0.0.1:${toString proxyPort} {
                    flush_interval -1
                  }
                '';
              }
          )
          services;
      };

      # Allow local Wi-Fi and NetBird to reach all active HTTPS ports (with connection limits)
      networking.firewall.extraCommands = ''
        ${lib.concatMapStringsSep "\n" (port: ''
          iptables -A nixos-fw -p tcp --dport ${toString port} -m connlimit --connlimit-above 80 -j REJECT
          iptables -A nixos-fw -p tcp --dport ${toString port} -s 192.168.0.0/16 -j nixos-fw-accept
          iptables -A nixos-fw -p tcp --dport ${toString port} -s 10.0.0.0/8 -j nixos-fw-accept
          iptables -A nixos-fw -p tcp --dport ${toString port} -s 100.64.0.0/10 -j nixos-fw-accept
        '') listenPorts}
      '';

      # Hardened systemd sandbox for Caddy process isolation
      systemd.services.caddy.serviceConfig = {
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        NoNewPrivileges = true;
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
        MemoryDenyWriteExecute = true;
      };
    };
  };
}
