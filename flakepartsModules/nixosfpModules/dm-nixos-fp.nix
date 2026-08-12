_: {
  flake.nixosModules.displayManager = {
    username,
    pkgs-unstable,
    ...
  }: {
    # Default display manager: ly TUI login manager
    services.displayManager.ly = {
      enable = true;
      package = pkgs-unstable.ly;
      settings = {
        # Active animation: John Conway's Game of Life
        #animation = "gameoflife";
        #gameoflife_fg = "0x0000FF00";        # Green cells
        #gameoflife_initial_density = 0.4;    # Balanced cell density
        #gameoflife_entropy_interval = 10;   # Prevents animation stabilization/stalling

        # Other available animations (uncomment to use):
        # animation = "doom";
        animation = "matrix";
        # animation = "colormix";
        # animation = "none";

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
