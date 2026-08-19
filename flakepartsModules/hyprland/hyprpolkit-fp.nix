_: {
  flake = {
    homeModules.nonDroid.hyprpolkit = {
      config,
      pkgs-unstable,
      lib,
      ...
    }: {
      services.hyprpolkitagent = {
        enable = config.wayland.windowManager.hyprland.enable;
        package = pkgs-unstable.hyprpolkitagent;
      };

      systemd.user.services.hyprpolkitagent = {
        Unit = {
          PartOf = lib.mkForce ["hyprland-session.target"];
          After = lib.mkForce ["hyprland-session.target"];
        };
        Install.WantedBy = lib.mkForce ["hyprland-session.target"];
      };
    };
  };
}
