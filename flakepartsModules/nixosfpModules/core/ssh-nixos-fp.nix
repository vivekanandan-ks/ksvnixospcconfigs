_: {
  flake.nixosModules.ssh = _: {
    # 3. Enable SSH Server
    services.openssh = {
      enable = true;
      settings = {
        # Optional: Disable password auth for security (if you set up keys)
        # PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };
}
