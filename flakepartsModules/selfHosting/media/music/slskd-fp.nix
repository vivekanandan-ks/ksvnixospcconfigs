{ inputs, lib, ... }: {
  flake.nixosModules.selfHosting = { pkgs, config, ... }: lib.mkIf (inputs ? nixflix) {
    # 1. Register decrypted secrets with sops-nix
    sops.secrets.slskd_web_password = { };
    sops.secrets.slskd_soulseek_password = { };

    # 2. Nixflix slskd Soulseek Client Service
    nixflix.slskd = {
      enable = true;
      user = "slskd";
      group = "media";

      # Web UI Credentials (http://<host>:5030)
      username = "admin";
      password._secret = config.sops.secrets.slskd_web_password.path;

      # Run directly on host for full peer discovery without VPN overhead
      vpn.enable = false;

      # Do not expose Soulseek listening port to public internet (outbound-only connections)
      openFirewall = false;

      settings = {
        web.port = 5030;

        # Soulseek network credentials
        soulseek = {
          username = "senku_music_node";
          password._secret = config.sops.secrets.slskd_soulseek_password.path;
        };

        directories = {
          # Download directly into shared music library for Navidrome & Jellyfin
          downloads = "/data/media/music";
          incomplete = "/data/torrents/incomplete/slskd";
        };

        # Share music library so peers do not auto-ban
        shares.directories = [
          "/data/media/music"
        ];

        # Strictly throttle upload bandwidth to avoid consuming home internet
        transfers.upload = {
          slots = 1;        # Only 1 concurrent uploader
          speed_limit = 50; # Capped to 50 KiB/s (~0.05 MB/s)
        };
      };
    };

    # 2. Grant slskd write permissions to /data/media/music
    users.users.slskd.extraGroups = [ "media" ];

    # 3. Prevent upstream nixpkgs slskd module from mounting /data/media/music read-only (due to shares.directories)
    systemd.services.slskd.serviceConfig.ReadOnlyPaths = lib.mkForce [ ];

    # 4. Restrict Web UI (Port 5030) ONLY to local Wi-Fi and NetBird (Blocked on public WAN)
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --dport 5030 -s 192.168.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport 5030 -s 10.0.0.0/8 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport 5030 -s 100.64.0.0/10 -j nixos-fw-accept
    '';
  };
}
