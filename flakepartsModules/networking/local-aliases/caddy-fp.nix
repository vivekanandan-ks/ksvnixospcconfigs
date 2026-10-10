{ lib, ... }: {
  flake.nixosModules.localAliases = { config, lib, ... }:
  let
    cfg = config.localAliases;
    hasAliases = cfg != { };
  in
  {
    config = lib.mkIf hasAliases {
      services.caddy = {
        enable = true;
        virtualHosts = lib.mapAttrs' (host: port:
          lib.nameValuePair "http://${host}" {
            extraConfig = ''
              reverse_proxy 127.0.0.1:${toString port} {
                flush_interval -1
              }
            '';
          }
        ) cfg;
      };

      networking.firewall.extraCommands = ''
        iptables -A nixos-fw -i wl+ -p tcp --dport 80 -s 192.168.0.0/16 -j nixos-fw-accept
        iptables -A nixos-fw -i wl+ -p tcp --dport 80 -s 10.0.0.0/8 -j nixos-fw-accept

        # Fast TCP Reset on port 443 so mobile browsers drop HTTPS-First probing in <1ms
        iptables -A nixos-fw -i wl+ -p tcp --dport 443 -s 192.168.0.0/16 -j REJECT --reject-with tcp-reset
        iptables -A nixos-fw -i wl+ -p tcp --dport 443 -s 10.0.0.0/8 -j REJECT --reject-with tcp-reset
      '';
    };
  };
}
