{ ... }: {
  flake.nixosModules.selfHosting = let
    port = 25600;
  in {
    # 1. Dedicated Manga, Manhwa, and Comic Media Server
    services.komga = {
      enable = true;
      group = "media";
      settings = {
        server = {
          inherit port;
        };
      };
    };

    localAliases."komga.local" = port;

    # Ensure komga system user has read/group access to /data/media/manga
    users.users.komga.extraGroups = [ "media" ];

    # Deprioritize background scanning I/O
    systemd.services.komga.serviceConfig = {
      Nice = 10;
      IOSchedulingClass = "best-effort";
      IOSchedulingPriority = 7;
    };

    # 2. Allow incoming reader connections strictly from local home LAN (NetBird wt0 is trusted)
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --dport ${toString port} -s 192.168.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport ${toString port} -s 10.0.0.0/8 -j nixos-fw-accept
    '';
  };
}
