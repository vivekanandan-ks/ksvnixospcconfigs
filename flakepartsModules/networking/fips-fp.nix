{
  inputs,
  lib,
  ...
}: {
  # ---------------------------------------------------------------------------
  # 1. Flake-File Input Declaration (in the same file)
  # ---------------------------------------------------------------------------
  flake-file.inputs = {
    fips = {
      url = "github:jmcorgan/fips";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # ---------------------------------------------------------------------------
  # 2. Main FIPS Module (Public node, multi-transport, zero-trust interface)
  # ---------------------------------------------------------------------------
  flake.nixosModules = lib.optionalAttrs (inputs ? fips) {
    fips = {
      config,
      pkgs,
      username,
      ...
    }: let
    # Hostname -> Ethernet Interface mapping (Zero options boilerplate)
    hostEthernetMap = {
      ksvnixospc = "enp3s0";
      deejunixospc = "enp2s0";
      akashnixospc = "eth0"; # Update with akashnixospc's NIC if different
    };

    myEthernetInterface = hostEthernetMap.${config.networking.hostName} or "eth0";

    # Personal cluster nodes with deterministic identities
    personalPeers = [
      {
        npub = "npub1rvktpk20ellsxaup4zlq8970evkhvkhc4jfn9pk5pl7asqmyqxssmzx0ds";
        alias = "ksvnixospc";
        via_nostr = true;
        connect_policy = "auto_connect";
      }
      {
        npub = "npub1plqchsrusewl6tkq477fy242g6u8cpxxa5su7d0dcrtrx02dkfaqfuv662";
        alias = "deejunixospc";
        via_nostr = true;
        connect_policy = "auto_connect";
      }
      {
        npub = "npub12azxft0e8kqrz0vpetfa532nd9qxnytsh32vhq3n7d625rvcwp0q63ylwl";
        alias = "akashnixospc";
        via_nostr = true;
        connect_policy = "auto_connect";
      }
    ];

    # Declarative YAML generation for /var/lib/fips/fips.yaml
    fipsConfig = (pkgs.formats.yaml {}).generate "fips.yaml" {
      node = {
        identity = {
          # Permanent identity preserved in /var/lib/fips/fips.key across reboots
          persistent = true;
        };
        rendezvous = {
          # Nostr internet discovery using creator's built-in default relays
          nostr = {
            enabled = true;
            advertise = true;
            policy = "open"; # Ambient public discovery like standard Yggdrasil
          };
          # Local mDNS discovery for sub-second pairing on local Wi-Fi / LAN
          lan = {
            enabled = true;
          };
        };
      };

      tun = {
        enabled = true;
        name = "fips0";
        mtu = 1280;
      };

      dns = {
        enabled = true;
        bind_addr = "::1";
        port = 5354;
      };

      transports = {
        # 1. Internet UDP transport with STUN NAT hole-punching
        udp = {
          bind_addr = "0.0.0.0:2121";
          advertise_on_nostr = true;
          public = false; # STUN hole-punching for p2p peering through NAT
          accept_connections = true;
        };

        # 2. Raw L2 Ethernet transport (offline cables / switch)
        ethernet = {
          interface = myEthernetInterface;
          optional = true; # Safe: daemon will not fail if unplugged
          announce = true; # Broadcast 34-byte beacons (EtherType 0x2121)
          listen = true;
          auto_connect = true;
          accept_connections = true;
        };

        # 3. Bluetooth BLE transport (offline in-room mesh, defaults to hci0)
        ble = {
          advertise = true; # Broadcasts FIPS BLE service UUID into the room
          scan = true; # Scans 2.4 GHz airwaves for nearby peers
          auto_connect = true;
          accept_connections = true;
        };
      };

      # Public Bootstrap Peers (connects your node to the global public mesh)
      peers = [
        {
          npub = "npub1qmc3cvfz0yu2hx96nq3gp55zdan2qclealn7xshgr448d3nh6lks7zel98";
          alias = "test-us01";
          addresses = [
            {
              transport = "udp";
              addr = "test-us01.fips.network:2121";
            }
          ];
          connect_policy = "auto_connect";
        }
        {
          npub = "npub1260n42s06vzc7796w0fh3ny7zcpw6tlk4gq3940gmfrzl5c9pv2s3657q8";
          alias = "test-de01";
          addresses = [
            {
              transport = "udp";
              addr = "test-de01.fips.network:2121";
            }
          ];
          connect_policy = "auto_connect";
        }
      ] ++ (builtins.filter (p: p.alias != config.networking.hostName) personalPeers);
    };
  in {
    imports = [
      inputs.fips.nixosModules.default
    ];

    nixpkgs.overlays = [
      inputs.fips.overlays.default
    ];

    # Enable FIPS service (disable upstream global resolved pollution)
    services.fips = {
      enable = true;
      openFirewall = true; # Opens UDP 2121 on physical interfaces for mesh wire packets
      configFile = fipsConfig;
      dns.enable = false; # Handled natively via dnsDelegates below
    };

    # Make CLI tools (fipsctl, fipstop) available in user PATH
    environment.systemPackages = [
      config.services.fips.package
    ];

    # Allow user to run fipsctl / fipstop without sudo
    users.users.${username}.extraGroups = [ "fips" ];

    # Native NixOS Split DNS Delegation (systemd 258+ / systemd.dns-delegate(5))
    services.resolved.dnsDelegates."fips".Delegate = {
      DNS = "[::1]:5354";
      Domains = "fips";
    };

    # Ensure Bluetooth daemon is available for the BLE transport
    hardware.bluetooth.enable = lib.mkDefault true;

    # -------------------------------------------------------------------------
    # SECURITY: Mirroring your Yggdrasil Security Model
    # -------------------------------------------------------------------------
    # 1. Do NOT add "fips0" to networking.firewall.trustedInterfaces.
    # 2. Block all inbound traffic arriving on fips0 by default.
    networking.firewall.interfaces."fips0".allowedTCPPorts = [];
    networking.firewall.interfaces."fips0".allowedUDPPorts = [];
  };
};

# ---------------------------------------------------------------------------
# 3. Host-Specific SOPS Secrets Mapping
# ---------------------------------------------------------------------------
flake.hostModules = lib.optionalAttrs (inputs ? fips) {
  ksvnixospc.fips = { ... }: {
    sops.secrets.fips_key_ksvnixospc = {
      path = "/var/lib/fips/fips.key";
      owner = "root";
      group = "fips";
      mode = "0600";
    };
  };

  deejunixospc.fips = { ... }: {
    sops.secrets.fips_key_deejunixospc = {
      path = "/var/lib/fips/fips.key";
      owner = "root";
      group = "fips";
      mode = "0600";
    };
  };

  akashnixospc.fips = { ... }: {
    sops.secrets.fips_key_akashnixospc = {
      path = "/var/lib/fips/fips.key";
      owner = "root";
      group = "fips";
      mode = "0600";
    };
  };
};
}
