_: {
  flake.nixosModules.crowdsec = {
    # 1. CrowdSec Security Engine
    services.crowdsec = {
      enable = true;
      autoUpdateService = true; # Daily threat intelligence updates

      # Automatically pull Caddy and HTTP vulnerability scenarios
      hub.collections = [
        "crowdsecurity/caddy"
        "crowdsecurity/http-cve"
      ];

      settings = {
        # Read Caddy's structured JSON logs directly from systemd journal
        acquisitions = [
          {
            source = "journalctl";
            journalctl_filter = [
              "_SYSTEMD_UNIT=caddy.service"
            ];
            labels = {
              type = "caddy";
            };
          }
        ];

        # Crucial: Whitelist trusted home subnets to prevent accidental self-bans
        parsers.s02Enrich = [
          {
            name = "homelab/whitelist";
            description = "Whitelist trusted private subnets from bans";
            whitelist = {
              cidr = [
                "127.0.0.0/8"
                "::1/128"
                "192.168.0.0/16"
                "10.0.0.0/8"
                "100.64.0.0/10"
              ];
              reason = "Trusted LAN and NetBird overlay devices";
            };
          }
        ];
      };
    };

    # 2. Kernel Firewall Bouncer (drops attacker IPs in iptables)
    services.crowdsec-firewall-bouncer = {
      enable = true;
      registerBouncer.enable = true;
    };
  };
}
