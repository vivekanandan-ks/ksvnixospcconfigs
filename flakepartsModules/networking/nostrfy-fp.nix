{
  self,
  inputs,
  lib,
  ...
}: let
  # Verified public relays with active NIP-77 Negentropy support
  negentropyRelays = [
    "wss://relay.ngit.dev"
    "wss://gitnostr.com"
    "wss://relay.damus.io"
    "wss://nos.lol"
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
  # ---------------------------------------------------------------------------
  # 1. Package nostrfy under perSystem (Available across all flake systems)
  # ---------------------------------------------------------------------------
  perSystem = {pkgs, ...}: {
    packages.nostrfy = pkgs.rustPlatform.buildRustPackage rec {
      pname = "nostrfy";
      version = "0.1.19";

      src = pkgs.fetchFromGitHub {
        owner = "iqbqioza";
        repo = "nostrfy";
        rev = "v${version}";
        hash = "sha256-CIvQVLMopdnZ++UyymHSOc8yyJgAC7sw0L+VjnXdW+Q=";
      };

      cargoLock.lockFile = "${src}/Cargo.lock";
      doCheck = false;

      meta = with lib; {
        description = "High-performance Nostr relay & Blossom server in Rust";
        homepage = "https://github.com/iqbqioza/nostrfy";
        license = with licenses; [mit asl20];
        mainProgram = "nostrfy";
      };
    };
  };

  # ---------------------------------------------------------------------------
  # 2. NixOS Module with SOPS-Managed Secret & 4-Hour Negentropy Catchup
  # ---------------------------------------------------------------------------
  flake.nixosModules.nostr = {
    config,
    lib,
    pkgs,
    ...
  }: let
    nostrfyPkg = self.packages.${pkgs.stdenv.hostPlatform.system}.nostrfy;
    blossomHost =
      self.personas.ksv.network.netbird.hosts.${config.networking.hostName}
      or "127.0.0.1";
    blossomAllowedNpubs = [
      self.personas.ksv.nostr.npub
    ];
  in {
    # Dedicated system user and group
    users.users.nostrfy = {
      isSystemUser = true;
      group = "nostrfy";
      home = "/var/lib/nostrfy";
      createHome = true;
    };
    users.groups.nostrfy = {};

    # SOPS Secret Declaration
    sops.secrets.nostrfy_relay_private_key = {};

    # Render nostrfy.toml directly in RAM (/run/secrets-rendered/)
    sops.templates."nostrfy.toml" = {
      owner = "nostrfy";
      group = "nostrfy";
      mode = "0400";
      content = ''
        [relay]
        name = "KSV Private Nostr Relay"
        description = "High-performance Nostr relay & Blossom server synchronized over NetBird"
        pubkey = "${self.personas.ksv.nostr.pubkeyHex}"
        private_key = "${config.sops.placeholder.nostrfy_relay_private_key}"
        contact = "mailto:${self.personas.ksv.email}"
        enabled_git = true
        enabled_nip78_auth = true
        send_auth_challenge = true

        [server]
        host = "0.0.0.0"
        port = 7777
        metrics_enabled = true

        [database]
        path = "/var/lib/nostrfy/data"
        search_index = true

        [daemon]
        pid_file = "/var/lib/nostrfy/nostrfy.pid"
        log_file = "/var/lib/nostrfy/nostrfy.log"
        stats_file = "/var/lib/nostrfy/nostrfy.stats.json"

        [blossom]
        host = "${blossomHost}"
        storage = "local"
        local_path = "/var/lib/nostrfy/blobs"
        max_upload_bytes = 52428800
        restrict_uploads = true
      '';
    };

    # Systemd Daemon for nostrfy
    systemd.services.nostrfy = {
      description = "nostrfy - Full-Stack Nostr & Blossom Relay";
      after = ["network.target" "sops-nix.service"];
      wantedBy = ["multi-user.target"];

      preStart = ''
        mkdir -p /var/lib/nostrfy/data /var/lib/nostrfy/blobs
        # Declaratively ensure our npub is allowlisted for Blossom uploads
        for npub in ${lib.escapeShellArgs blossomAllowedNpubs}; do
          ${nostrfyPkg}/bin/nostrfy --config ${config.sops.templates."nostrfy.toml".path} blossom allow "$npub" || true
        done
      '';

      serviceConfig = {
        ExecStart = "${nostrfyPkg}/bin/nostrfy --config ${config.sops.templates."nostrfy.toml".path} start --foreground";
        User = "nostrfy";
        Group = "nostrfy";
        WorkingDirectory = "/var/lib/nostrfy";
        Restart = "always";
        RestartSec = "5s";
        LimitNOFILE = 65536;
      };
    };

    # Firewall: Open port 7777 ONLY on NetBird (wt0)
    networking.firewall.interfaces."wt0".allowedTCPPorts = [7777];

    # CLI tools
    environment.systemPackages = with pkgs; [
      nostrfyPkg
      # gossip # Native Rust desktop client (NIP-65) - commented out
      nak
    ];

    # Automated Catch-Up Service using NIP-77 Negentropy
    systemd.services.nostrfy-catchup = lib.mkIf (self.personas.ksv.nostr.npub != "") {
      description = "Catch-up sync personal notes from public relays via NIP-77";
      after = ["network-online.target" "nostrfy.service"];
      wants = ["network-online.target"];

      serviceConfig = {
        Type = "oneshot";
        User = "nostrfy";
        WorkingDirectory = "/var/lib/nostrfy";
        Environment = [
          "HOME=/var/lib/nostrfy"
          "XDG_CONFIG_HOME=/var/lib/nostrfy/.config"
          "XDG_DATA_HOME=/var/lib/nostrfy/.local/share"
        ];
        ExecStart = pkgs.writeShellScript "nostrfy-catchup-sync" ''
          # Phase 1: Aggregate (Pull from all relays)
          for relay in ${lib.escapeShellArgs negentropyRelays}; do
            ${pkgs.coreutils}/bin/timeout 15s ${pkgs.nak}/bin/nak sync \
              "$relay" \
              ws://127.0.0.1:7777 \
              --author "${self.personas.ksv.nostr.npub}" || true
            sleep 1
          done

          # Phase 2: Propagate (Push to all relays)
          for relay in ${lib.escapeShellArgs negentropyRelays}; do
            ${pkgs.coreutils}/bin/timeout 15s ${pkgs.nak}/bin/nak sync \
              ws://127.0.0.1:7777 \
              "$relay" \
              --author "${self.personas.ksv.nostr.npub}" || true
            sleep 1
          done
        '';
      };
    };

    # Timer: 4-Hour Interval with Jitter to Eliminate Rate Limits
    systemd.timers.nostrfy-catchup = lib.mkIf (self.personas.ksv.nostr.npub != "") {
      description = "Timer for Nostr catch-up sync";
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
