_: {
  flake.nixosModules.displayManager = {username, ...}: {
    # Default display manager: ly TUI login manager
    services.displayManager.ly = {
      enable = true;
      settings = {
        animation = "doom";
        save = true;
      };
    };

    # SDDM disabled by default across all hosts
    # (Can be enabled per host using `services.displayManager.ly.enable = lib.mkForce false;` and `services.displayManager.sddm.enable = lib.mkForce true;`)
    services.displayManager.sddm.enable = false;

    # Enable automatic login for the user
    services.displayManager.autoLogin = {
      enable = true;
      user = username;
    };
  };
}
