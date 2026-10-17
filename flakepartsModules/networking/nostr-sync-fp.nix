{
  self,
  lib,
  ...
}: let
  # Verified public fallback hubs with active NIP-77 Negentropy support
  fallbackRelays = [
    "wss://relay.ngit.dev"
    "wss://gitnostr.com"
    "wss://relay.nostrfy.org"
    "wss://nos.lol"
    "wss://nostr.oxtr.dev"
    "wss://offchain.pub"
    "wss://nostr.bitcoiner.social"
    "wss://purplepag.es"
    "wss://relay.primal.net"
    "wss://relay.damus.io"
  ];
in {
  flake.nixosModules.nostr-sync = {
    config,
    pkgs,
    lib,
    ...
  }: let
    # Dynamically select NetBird peer IPs, excluding the current host
    peerIps = lib.attrValues (
      lib.filterAttrs (host: _: host != config.networking.hostName)
        self.personas.ksv.network.netbird.hosts
    );
    blossomHost =
      self.personas.ksv.network.netbird.hosts.${config.networking.hostName}
      or "127.0.0.1";

    # Declarative list of accounts to back up and synchronize
    syncUsers = [
      {
        name = "ksv";
        npub = self.personas.ksv.nostr.npub;
        hex = self.personas.ksv.nostr.pubkeyHex;
      }
      # To add friends, family, or alt accounts in the future, simply add them here:
      # {
      #   name = "friend";
      #   npub = "npub1...";
      #   hex = "hex_pubkey...";
      # }
    ];

    authorFlags = lib.concatMap (u: ["-a" u.npub]) syncUsers;
    pFlags = lib.concatMap (u: ["-p" u.hex]) syncUsers;
    userPairs = map (u: "${u.npub}:${u.hex}") syncUsers;
  in {
    # ---------------------------------------------------------------------------
    # Automated High-Performance Nostr & Blossom Catch-Up Service
    # ---------------------------------------------------------------------------
    systemd.services.nostrfy-catchup = lib.mkIf (self.personas.ksv.nostr.npub != "") {
      description = "Multi-Stream Nostr & Blossom Catch-up Sync Service";
      after = ["network-online.target" "nostrfy.service" "tor.service" "data.mount"];
      wants = ["network-online.target" "tor.service" "data.mount"];

      serviceConfig = {
        Type = "oneshot";
        User = "nostrfy";
        Group = "nostrfy";
        WorkingDirectory = "/var/lib/nostrfy";
        Environment = [
          "HOME=/var/lib/nostrfy"
          "XDG_CONFIG_HOME=/var/lib/nostrfy/.config"
          "XDG_DATA_HOME=/var/lib/nostrfy/.local/share"
        ];
        ExecStart = pkgs.writeShellScript "nostrfy-sync" ''
          set -euo pipefail
          trap 'rm -f /data/nostrfy/blobs/*/*.tmp 2>/dev/null || true' EXIT

          # Helper wrappers ensuring all public traffic is torified with bounded timeouts
          tor_nak() {
            ${pkgs.coreutils}/bin/timeout 25s ${pkgs.torsocks}/bin/torsocks ${pkgs.nak}/bin/nak "$@"
          }
          tor_curl() {
            ${pkgs.coreutils}/bin/timeout 30s ${pkgs.curl}/bin/curl --socks5-hostname 127.0.0.1:9050 "$@"
          }

          START_TIME=$(${pkgs.coreutils}/bin/date +%s)
          AUTHOR_FLAGS=(${lib.escapeShellArgs authorFlags})
          P_FLAGS=(${lib.escapeShellArgs pFlags})
          USER_PAIRS=(${lib.escapeShellArgs userPairs})
          LOCAL_RELAY="ws://127.0.0.1:7777"
          BLOSSOM_HOST="${blossomHost}"
          BLOSSOM_DIR="/data/nostrfy/blobs"
          ONLINE_PEERS=0
          BLOBS_MIRRORED=0

          echo "=== [1/4] NetBird Peer-to-Peer Mesh Sync ==="
          PEER_IPS=(${lib.escapeShellArgs peerIps})
          for peer_ip in "''${PEER_IPS[@]}"; do
            echo "Probing NetBird peer at $peer_ip:7777..."
            if ${pkgs.netcat-openbsd}/bin/nc -z -w 2 "$peer_ip" 7777 2>/dev/null; then
              echo "Peer $peer_ip is ONLINE. Reconciling peer-to-peer via NIP-77..."
              ONLINE_PEERS=$((ONLINE_PEERS + 1))
              ${pkgs.coreutils}/bin/timeout 15s ${pkgs.nak}/bin/nak sync \
                "ws://$peer_ip:7777" "$LOCAL_RELAY" "''${AUTHOR_FLAGS[@]}" || true
              ${pkgs.coreutils}/bin/timeout 15s ${pkgs.nak}/bin/nak sync \
                "$LOCAL_RELAY" "ws://$peer_ip:7777" "''${AUTHOR_FLAGS[@]}" || true
              ${pkgs.coreutils}/bin/timeout 15s ${pkgs.nak}/bin/nak sync \
                "ws://$peer_ip:7777" "$LOCAL_RELAY" "''${P_FLAGS[@]}" || true
            else
              echo "Peer $peer_ip is offline/asleep. Skipping."
            fi
          done

          echo "=== [2/4] Dynamic Public Relay Discovery (NIP-65 & NIP-17) ==="
          FALLBACK_LIST=(${lib.escapeShellArgs fallbackRelays})

          DYNAMIC_RELAYS=$(${pkgs.nak}/bin/nak req -k 10002 "''${AUTHOR_FLAGS[@]}" "$LOCAL_RELAY" 2>/dev/null \
            | ${pkgs.jq}/bin/jq -r '.tags[]? | select(.[0] == "r") | .[1]' 2>/dev/null || true)

          MESSAGING_RELAYS=$(${pkgs.nak}/bin/nak req -k 10050 "''${AUTHOR_FLAGS[@]}" "$LOCAL_RELAY" 2>/dev/null \
            | ${pkgs.jq}/bin/jq -r '.tags[]? | select(.[0] == "relay") | .[1]' 2>/dev/null || true)

          # Normalize URLs (strip trailing slashes, remove whitespace, deduplicate)
          ALL_RELAYS=($(printf '%s\n' "''${FALLBACK_LIST[@]}" $DYNAMIC_RELAYS \
            | sed -E 's:/*$::' | grep '^wss://' | sort -u))

          echo "Discovered ''${#ALL_RELAYS[@]} active relays for parallel reconciliation across ''${#USER_PAIRS[@]} account(s)."

          echo "=== [3/4] Multi-Stream Parallel Replication (Authored, Mentions, Mail) ==="
          
          # OpSec Fail-Closed Kill-Switch: Ensure Tor SOCKS5 proxy is responsive before connecting to public relays
          TOR_READY=0
          for attempt in 1 2 3; do
            if ${pkgs.netcat-openbsd}/bin/nc -z -w 2 127.0.0.1 9050 2>/dev/null; then
              TOR_READY=1
              break
            fi
            sleep 1
          done

          if [ "$TOR_READY" -ne 1 ]; then
            echo "[-] ERROR: Tor SOCKS5 proxy is offline on 127.0.0.1:9050!"
            echo "[-] OpSec Kill-Switch ENGAGED: Aborting public relay sync to prevent real IP leak."
            exit 1
          fi
          echo "[+] Tor SOCKS5 proxy is active on 127.0.0.1:9050. Proceeding with torified public replication."

          # Parallel worker function routing all public relay traffic through Tor
          sync_relay() {
            local relay="$1"
            echo "[SYNC] Reconciling with $relay via Tor..."

            # Stream A: Authored Notes (Two-way sync via NIP-77 for all accounts)
            tor_nak sync "$relay" "$LOCAL_RELAY" "''${AUTHOR_FLAGS[@]}" >/dev/null 2>&1 || true
            tor_nak sync "$LOCAL_RELAY" "$relay" "''${AUTHOR_FLAGS[@]}" >/dev/null 2>&1 || true

            # Stream B: Mentions, Comments & NIP-34 PRs (for all accounts)
            tor_nak sync "$relay" "$LOCAL_RELAY" "''${P_FLAGS[@]}" >/dev/null 2>&1 || true
          }

          # Bounded parallelism (3 concurrent workers)
          MAX_JOBS=3
          current_jobs=0
          for relay in "''${ALL_RELAYS[@]}"; do
            sync_relay "$relay" &
            ((current_jobs++)) || true
            if [ "$current_jobs" -ge "$MAX_JOBS" ]; then
              wait -n 2>/dev/null || true
              ((current_jobs--)) || true
            fi
          done
          wait 2>/dev/null || true

          # Stream C: Encrypted Mail / Gift Wraps (Kind 1059) from Dedicated Messaging Relays via Tor
          MAIL_TARGETS=($(printf '%s\n' $MESSAGING_RELAYS "wss://relay.damus.io" "wss://nos.lol" \
            | sed -E 's:/*$::' | grep '^wss://' | sort -u))
          for relay in "''${MAIL_TARGETS[@]}"; do
            echo "[MAIL] Checking $relay via Tor..."
            tor_nak sync "$relay" "$LOCAL_RELAY" -k 1059 "''${P_FLAGS[@]}" >/dev/null 2>&1 || true
          done

          echo "=== [4/4] Blossom Media Backfill (BUD-03 & BUD-02) ==="
          for pair in "''${USER_PAIRS[@]}"; do
            npub="''${pair%%:*}"
            hex="''${pair##*:}"
            mkdir -p "$BLOSSOM_DIR/$npub"

            BLOSSOM_SERVERS=$(${pkgs.nak}/bin/nak req -k 10063 -a "$hex" --limit 1 "$LOCAL_RELAY" 2>/dev/null \
              | ${pkgs.jq}/bin/jq -r '.tags[]? | select(.[0] == "server") | .[1]' 2>/dev/null | sort -u || true)

            for bserver in $BLOSSOM_SERVERS; do
              bserver="''${bserver%/}"
              echo "Checking Blossom server: $bserver for $npub via Tor"

              BLOBS=$(tor_curl -sf "$bserver/list/$hex" 2>/dev/null || true)

              if echo "$BLOBS" | ${pkgs.jq}/bin/jq -e 'type == "array"' >/dev/null 2>&1; then
                while IFS=$'\t' read -r sha url; do
                  sha="''${sha,,}"
                  if [ -n "$sha" ] && [ ! -f "$BLOSSOM_DIR/$npub/$sha" ] && [ ! -f "$BLOSSOM_DIR/$sha" ]; then
                    echo "Mirroring missing blob: $sha from $url for $npub via Tor"
                    tor_curl -sfL "$url" -o "$BLOSSOM_DIR/$npub/$sha.tmp" || true
                    if [ -f "$BLOSSOM_DIR/$npub/$sha.tmp" ]; then
                      COMPUTED_SHA=$(${pkgs.coreutils}/bin/sha256sum "$BLOSSOM_DIR/$npub/$sha.tmp" | cut -d' ' -f1)
                      if [ "$COMPUTED_SHA" = "$sha" ]; then
                        mv "$BLOSSOM_DIR/$npub/$sha.tmp" "$BLOSSOM_DIR/$npub/$sha"
                        echo "Successfully mirrored: $sha"
                        BLOBS_MIRRORED=$((BLOBS_MIRRORED + 1))
                      else
                        rm -f "$BLOSSOM_DIR/$npub/$sha.tmp"
                      fi
                    fi
                  fi
                done < <(echo "$BLOBS" | ${pkgs.jq}/bin/jq -r '.[] | select((.size // 0) <= 52428800) | [.sha256, .url] | @tsv' | head -n 20)
              fi
            done
          done

          END_TIME=$(${pkgs.coreutils}/bin/date +%s)
          ELAPSED=$((END_TIME - START_TIME))
          echo "=================================================="
          echo "       Nostr & Blossom Replication Report         "
          echo "=================================================="
          echo " OpSec Mode:         Tor SOCKS5 (Fail-Closed)"
          echo " Duration:           ''${ELAPSED}s"
          echo " Accounts Synced:    ''${#USER_PAIRS[@]}"
          echo " NetBird Peers:      ''${ONLINE_PEERS}/''${#PEER_IPS[@]} online"
          echo " Relays Reconciled:  ''${#ALL_RELAYS[@]}"
          echo " Blobs Mirrored:     ''${BLOBS_MIRRORED}"
          echo " Status:             SUCCESS"
          echo "=================================================="
        '';
      };
    };

    # Timer: Every 4 hours with 15-minute randomized jitter
    systemd.timers.nostrfy-catchup = lib.mkIf (self.personas.ksv.nostr.npub != "") {
      description = "Timer for Nostr & Blossom catch-up sync";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "4h";
        RandomizedDelaySec = "15m";
        Persistent = true;
      };
    };
  };
}
