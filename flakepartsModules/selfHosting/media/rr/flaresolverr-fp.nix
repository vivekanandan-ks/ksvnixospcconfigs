{ inputs, lib, ... }: {
  flake.nixosModules.selfHosting = lib.mkIf (inputs ? nixflix) {
    nixflix.flaresolverr = {
      enable = true;
      port = 8191;
    };

    # Prevent Chromium startup from timing out on cold-boot HDD or starving the desktop
    systemd.services.flaresolverr.serviceConfig = {
      TimeoutStartSec = 120;
      Nice = 10;
      IOSchedulingClass = "best-effort";
      IOSchedulingPriority = 7;
    };

    # Allow local home Wi-Fi to reach the FlareSolverr status endpoint
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --dport 8191 -s 192.168.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport 8191 -s 10.0.0.0/8 -j nixos-fw-accept
    '';
  };
}
