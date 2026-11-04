_: {
  flake.nixosModules.displayManager = {
    config,
    lib,
    username,
    ...
  }: let
    targetUser =
      if config.services.displayManager.autoLogin.user != null
      then config.services.displayManager.autoLogin.user
      else username;
  in {
    imports = [
      # Compatibility alias: dux-greeter checks `programs.mangowc` instead of `programs.mango`
      (lib.mkAliasOptionModule [ "programs" "mangowc" ] [ "programs" "mango" ])
    ];

    # Default display manager: Dux Greeter (greetd + Quickshell)
    services.displayManager.dux-greeter = {
      enable = true;
      compositor.name = "mangowc";
      configHome = config.users.users.${targetUser}.home;
    };

    # SDDM disabled by default across all hosts
    # (Can be enabled per host using `services.displayManager.dux-greeter.enable = lib.mkForce false;` and `services.displayManager.sddm.enable = lib.mkForce true;`)
    services.displayManager.sddm.enable = false;

    # Enable automatic login for the user
    services.displayManager.autoLogin = {
      enable = true;
      user = username;
    };

    # Default session for display manager and auto-login
    services.displayManager.defaultSession = "mango";
  };
}
