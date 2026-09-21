_: {
  # Common baseline Yggdrasil configuration for all hosts
  flake.nixosModules.yggdrasil = {
    lib,
    pkgs-unstable,
    ...
  }: {
    services.yggdrasil = {
      enable = true;
      package = pkgs-unstable.yggdrasil;

      # Default to true for all hosts; can be overridden per host via hostModules
      persistentKeys = lib.mkDefault true;

      # Allow wheel group members to run `yggdrasilctl` without sudo
      group = "wheel";

      # Disable local LAN multicast peer discovery (NetBird handles private networking)
      openMulticastPort = false;

      settings = {
        # Client-only: Do NOT listen for incoming peering connections on the clearnet
        Listen = [];

        # Outbound peers
        Peers = [
          "tls://ins.8px.sk:4321"
          "quic://ins.8px.sk:4321"
        ];
      };
    };

    # Make `yggdrasil` and `yggdrasilctl` CLI tools available in PATH
    environment.systemPackages = [
      pkgs-unstable.yggdrasil
    ];

    # Security:
    # - Do NOT add "ygg0" to networking.firewall.trustedInterfaces.
    # - No inbound ports (SSH 22, etc.) are opened on ygg0; inbound mesh traffic is blocked.
  };

  # Host-specific SOPS key override for deejunixospc
  flake.hostModules.deejunixospc.yggdrasil = {
    config,
    lib,
    ...
  }: {
    sops.secrets.yggdrasil_key_deejunixospc = {};

    services.yggdrasil = {
      persistentKeys = lib.mkForce false;
      settings.PrivateKeyPath = config.sops.secrets.yggdrasil_key_deejunixospc.path;
    };
  };

  # Host-specific SOPS key override for ksvnixospc
  flake.hostModules.ksvnixospc.yggdrasil = {
    config,
    lib,
    ...
  }: {
    sops.secrets.yggdrasil_key_ksvnixospc = {};

    services.yggdrasil = {
      persistentKeys = lib.mkForce false;
      settings.PrivateKeyPath = config.sops.secrets.yggdrasil_key_ksvnixospc.path;
    };
  };

  flake.hostModules.akashnixospc.yggdrasil = {
    config,
    lib,
    ...
  }: {
    sops.secrets.yggdrasil_key_akashnixospc = {};
    services.yggdrasil = {
      persistentKeys = lib.mkForce false;
      settings.PrivateKeyPath = config.sops.secrets.yggdrasil_key_akashnixospc.path;
    };
  };
}
