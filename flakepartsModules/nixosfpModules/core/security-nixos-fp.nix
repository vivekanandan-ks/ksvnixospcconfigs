_: {
  flake.nixosModules.security = {
    # Replace legacy C sudo with memory-safe Rust sudo-rs
    security.sudo-rs.enable = true;

    # Desktop security auditing monitor
    services.paretosecurity = {
      enable = true;
      trayIcon = true;
    };
  };
}
