{ inputs, lib, ... }: {
  flake.nixosModules.selfHosting = { pkgs, ... }: lib.mkIf (inputs ? nixflix) {
    nixflix.radarr = {
      enable = true;
      config = {
        apiKey = "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6";
        hostConfig = {
          username = "admin";
          password = "admin123";
          updateMechanism = "external";
        };
      };
    };

    # Give Radarr ample time to initialize SQLite DB and ensure AllowedHosts is empty so 0.0.0.0 is accepted
    systemd.services.radarr = {
      preStart = ''
        if [ -f /var/lib/radarr/config.xml ]; then
          ${pkgs.gnused}/bin/sed -i 's|<AllowedHosts>.*</AllowedHosts>|<AllowedHosts></AllowedHosts>|g' /var/lib/radarr/config.xml
        fi
      '';
      serviceConfig = {
        TimeoutStartSec = 120;
        Nice = 10;
        IOSchedulingClass = "best-effort";
        IOSchedulingPriority = 7;
      };
    };

    systemd.services.radarr-config.serviceConfig = {
      TimeoutStartSec = 120;
      Nice = 10;
      IOSchedulingClass = "best-effort";
      IOSchedulingPriority = 7;
    };

    systemd.services.radarr-notifications.serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5s";
    };

    # Declarative size limits (~2.5GB ceiling for 2h film) and delete "Any"
    systemd.services.radarr-quality-limits = {
      description = "Enforce Radarr size sliders (~2.5GB ceiling) and remove 'Any' profile";
      after = [ "radarr.service" "radarr-config.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        API="a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6"
        BASE="http://127.0.0.1:7878/api/v3"

        for i in $(seq 1 60); do
          if ${pkgs.curl}/bin/curl -sf -H "X-Api-Key: $API" "$BASE/qualitydefinition" > /dev/null; then
            break
          fi
          sleep 2
        done

        CURRENT=$(${pkgs.curl}/bin/curl -sf -H "X-Api-Key: $API" "$BASE/qualitydefinition")
        if [ -n "$CURRENT" ]; then
          UPDATED=$(echo "$CURRENT" | ${pkgs.jq}/bin/jq '
            map(
              if (.title == "WEBDL-1080p" or .title == "WEBRip-1080p" or .title == "HDTV-1080p") then
                .minSize = 6 | .preferredSize = 16 | .maxSize = 21
              elif (.title | test("Bluray|Remux")) then
                .minSize = 0 | .preferredSize = 0 | .maxSize = 0
              else
                .
              end
            )
          ')
          ${pkgs.curl}/bin/curl -sf -X PUT -H "X-Api-Key: $API" -H "Content-Type: application/json" \
            --data "$UPDATED" "$BASE/qualitydefinition/update"
        fi

        ANY_ID=$(${pkgs.curl}/bin/curl -sf -H "X-Api-Key: $API" "$BASE/qualityprofile" | ${pkgs.jq}/bin/jq -r '.[] | select(.name == "Any") | .id' 2>/dev/null || true)
        if [ -n "$ANY_ID" ] && [ "$ANY_ID" != "null" ]; then
          ${pkgs.curl}/bin/curl -sf -X DELETE -H "X-Api-Key: $API" "$BASE/qualityprofile/$ANY_ID" || true
        fi
      '';
    };

    # Allow local home Wi-Fi to reach Radarr dashboard
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --dport 7878 -s 192.168.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport 7878 -s 10.0.0.0/8 -j nixos-fw-accept
    '';

    # Bypass Indian ISP dead-routing / 100% packet loss on Cloudflare IP 172.67.180.78
    networking.hosts = {
      "104.21.43.147" = [
        "api.radarr.video"
        "radarr.servarr.com"
      ];
    };
  };
}
