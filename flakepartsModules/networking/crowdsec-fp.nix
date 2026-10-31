_: {
  flake.nixosModules.crowdsec = {
    # 1. CrowdSec Security Engine
    services.crowdsec = {
      enable = true;
      autoUpdateService = true; # Daily threat intelligence updates

      # Automatically pull Caddy, HTTP, and SSH vulnerability scenarios
      hub.collections = [
        "crowdsecurity/caddy"
        "crowdsecurity/http-cve"
        "crowdsecurity/sshd"
        # --- Activate when opening services to the public internet ---
        # "crowdsecurity/base-http-scenarios"  # Deep web attack probing (currently bundled via crowdsecurity/caddy)
        # "crowdsecurity/appsec-generic-rules" # Real-time WAF rules (requires compiling an AppSec bouncer plugin into Caddy)
      ];

      settings = {
        # Read Caddy and SSH structured logs directly from systemd journal
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
          {
            source = "journalctl";
            journalctl_filter = [
              "_SYSTEMD_UNIT=sshd.service"
            ];
            labels = {
              type = "syslog";
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
