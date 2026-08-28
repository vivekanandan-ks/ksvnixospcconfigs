{inputs, ...}: {
  flake-file.inputs = {
    nixos-telemetry = {
      url = "github:mrVanDalo/nixos-telemetry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.nixosModules.telemetry = {
    imports = [
      inputs.nixos-telemetry.nixosModules.default
    ];

    telemetry = {
      enable = true;

      # Metric collection (CPU, RAM, Disks, Thermals, Process stats)
      telegraf = {
        enable = true;
        inputs.procstat.enable = true;
      };

      # Systemd journal log scraping
      alloy.enable = true;

      # Local storage backends
      prometheus = {
        enable = true;
        retentionTime = "14d";
      };
      loki.enable = true;

      # Local Grafana UI
      grafana = {
        enable = true;
        adminAccess = "anonymous";
        http_addr = "0.0.0.0"; # Accessible from mobile via NetBird
        http_port = 3000;
      };
    };
  };
}
