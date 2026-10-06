{ inputs, lib, ... }: {
  flake.nixosModules.selfHosting = { pkgs, ... }: lib.mkIf (inputs ? nixflix) {
    nixflix.sonarr = {
      enable = true;
      config = {
        apiKey = "b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6a1";
        hostConfig = {
          username = "admin";
          password = "admin123";
          updateMechanism = "external";
        };
      };
    };

    # Give Sonarr ample time to initialize SQLite DB without systemd killing it at boot
    systemd.services.sonarr.serviceConfig = {
      TimeoutStartSec = 120;
      Nice = 10;
      IOSchedulingClass = "best-effort";
      IOSchedulingPriority = 7;
    };
    systemd.services.sonarr-config.serviceConfig = {
      TimeoutStartSec = 120;
      Nice = 10;
      IOSchedulingClass = "best-effort";
      IOSchedulingPriority = 7;
    };

    # Declarative size limits (~810MB max per 45m episode) and delete "Any"
    systemd.services.sonarr-quality-limits = {
      description = "Enforce Sonarr size sliders (~810MB ceiling) and remove 'Any' profile";
      after = [ "sonarr.service" "sonarr-config.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        API="b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6a1"
        BASE="http://127.0.0.1:8989/api/v3"

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
                .minSize = 5 | .preferredSize = 12 | .maxSize = 18
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

    # Allow local home Wi-Fi to reach Sonarr dashboard
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --dport 8989 -s 192.168.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport 8989 -s 10.0.0.0/8 -j nixos-fw-accept
    '';
  };
}
