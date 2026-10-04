{ inputs, lib, ... }: {
  flake.nixosModules.selfHosting = { pkgs, ... }: lib.mkIf (inputs ? nixflix) {
    nixflix.flaresolverr = {
      enable = true;
      port = 8191;
    };

    # Prevent Chromium startup from timing out on cold-boot HDD or starving the desktop
    systemd.services.flaresolverr = {
      after = [ "nixflix-setup-dirs.service" "prowlarr.service" ];
      serviceConfig = {
        TimeoutStartSec = 240;
        Nice = 10;
        IOSchedulingClass = "best-effort";
        IOSchedulingPriority = 7;
        Environment = [ "LIBGL_ALWAYS_SOFTWARE=1" ];
        ExecStartPost = lib.mkForce [
          ""
          "${pkgs.writeShellScript "wait-for-flaresolverr" ''
            for i in $(seq 1 240); do
              if ${pkgs.curl}/bin/curl -sf http://127.0.0.1:8191/ >/dev/null 2>&1; then
                exit 0
              fi
              sleep 1
            done
            echo "FlareSolverr did not become ready within 240s"
            exit 1
          ''}"
        ];
      };
    };

    # Allow local home Wi-Fi to reach the FlareSolverr status endpoint
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --dport 8191 -s 192.168.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport 8191 -s 10.0.0.0/8 -j nixos-fw-accept
    '';
  };
}
