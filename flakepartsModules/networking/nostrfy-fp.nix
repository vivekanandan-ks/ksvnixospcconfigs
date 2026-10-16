{
  self,
  inputs,
  lib,
  ...
}: {
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
  # 2. NixOS Module: Relay Daemon, Blossom Media Server & Firewall
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
      nak
      jq
      netcat-openbsd
    ];
  };
}
