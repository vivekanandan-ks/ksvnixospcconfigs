_: {
  flake.nixosModules.ssh = _: {
    # 3. Enable SSH Server
    services.openssh = {
      enable = true;
      # Dual-Port Model:
      # - Port 22: NetBird intercepts on wt0 for Web Dashboard Browser Terminal
      # - Port 2222: Pure native OpenSSH for CLI key-based authentication
      ports = [
        22
        2222
      ];
      settings = {
        # Optional: Disable password auth for security (if you set up keys)
        # PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };
}
