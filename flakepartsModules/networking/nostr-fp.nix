_: {
  # Common baseline Nostr configuration imported across all hosts via `common-hosts-fp.nix`
  flake.nixosModules.nostr = {
    lib,
    pkgs,
    ...
  }: let
    # When set, it activates the automated catch-up sync timer across all hosts.
    # Hex equivalent: efbfbcecfa80a34df203925cbac8fbb2223f8e6c77877c6d546e5ce3ce833922
    myPubkey = "npub1a7lmem86sz35musrjfwt4j8mkg3rlrnvw7rhcm25deww8n5r8y3qh62zpr";

    # Verified public strfry relays with active NIP-77 Negentropy support
    negentropyRelays = [
      "wss://nostr.oxtr.dev"
      "wss://rele.speyhard.fi"
      "wss://mostro-p2p.tech"
      "wss://nostr.data.haus"
      "wss://relay.shadowbip.com"
      "wss://relay.nostrdvm.com"
      "wss://relay.contextvm.org"
      "wss://relay2.contextvm.org"
      "wss://nostr.bitcoiner.social"
      "wss://offchain.pub"
      "wss://nostr21.com"
      "wss://relay.mostr.pub"
    ];
  in {
    # 1. High-Performance C++ / LMDB Nostr Relay
    services.strfry = {
      enable = lib.mkDefault true;

      settings = {
        relay = {
          # Bind to 0.0.0.0 so it listens on localhost and NetBird (wt0)
          bind = "0.0.0.0";
          port = 7777;

          info = {
            name = "KSV Private Nostr Relay";
            description = "Personal Nostr relay synchronized over NetBird";
          };

          # Native Negentropy (NIP-77) high-speed set-reconciliation sync
          negentropy = {
            enabled = true;
          };
        };

        db = "/var/lib/strfry";
      };
    };

    # 2. Firewall Security: Open port 7777 ONLY on NetBird (wt0)
    # Keeps the relay completely invisible to public Wi-Fi/Ethernet,
    # while allowing your mobile phone and other NetBird nodes to connect.
    networking.firewall.interfaces."wt0".allowedTCPPorts = [7777];

    # 3. Nostr CLI & Desktop Client
    environment.systemPackages = with pkgs; [
      gossip # Native Rust desktop client (Outbox model / NIP-65)
      nak # Nostr Army Knife CLI (inspection, query, and Negentropy sync)
    ];

    # 4. Automated Catch-Up Service & Timer
    systemd.services.strfry-catchup = lib.mkIf (myPubkey != "") {
      description = "Catch-up sync personal notes from public relays";
      after = ["network-online.target" "strfry.service"];
      wants = ["network-online.target"];

      serviceConfig = {
        Type = "oneshot";
        User = "strfry";
        WorkingDirectory = "/var/lib/strfry";
        Environment = [
          "HOME=/var/lib/strfry"
          "XDG_CONFIG_HOME=/var/lib/strfry/.config"
          "XDG_DATA_HOME=/var/lib/strfry/.local/share"
        ];
        # Bidirectional sync personal notes using NIP-77 Negentropy over WebSockets:
        # Phase 1: Ingest/Pull from all relays to aggregate complete union locally.
        # Phase 2: Propagate/Push from local strfry to all relays for cross-relay healing.
        ExecStart = pkgs.writeShellScript "strfry-catchup-sync" ''
          # Phase 1: Aggregate (Pull from all relays)
          for relay in ${lib.escapeShellArgs negentropyRelays}; do
            ${pkgs.coreutils}/bin/timeout 15s ${pkgs.nak}/bin/nak sync \
              "$relay" \
              ws://127.0.0.1:7777 \
              --author "${myPubkey}" || true
          done

          # Phase 2: Propagate (Push to all relays)
          for relay in ${lib.escapeShellArgs negentropyRelays}; do
            ${pkgs.coreutils}/bin/timeout 15s ${pkgs.nak}/bin/nak sync \
              ws://127.0.0.1:7777 \
              "$relay" \
              --author "${myPubkey}" || true
          done
        '';
      };
    };

    systemd.timers.strfry-catchup = lib.mkIf (myPubkey != "") {
      description = "Timer for Nostr catch-up sync";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "30m";
        Persistent = true;
      };
    };
  };
}
