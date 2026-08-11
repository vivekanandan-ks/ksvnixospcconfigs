_: {
  flake.nixosModules.displayManager = {username, pkgs-unstable, ...}: {
    # Default display manager: ly TUI login manager
    services.displayManager.ly = {
      enable = true;
      package = pkgs-unstable.ly ;
      settings = {
        animation = "dur_file";
        dur_file_path = "${./blackhole.dur}";
        dur_offset_alignment = "center";
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
