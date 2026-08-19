_: {
  flake = {
    homeModules.nonDroid.hypridle = {
      config,
      pkgs-unstable,
      lib,
      ...
    }: {
      services.hypridle = {
        enable = config.wayland.windowManager.hyprland.enable;
        package = pkgs-unstable.hypridle;
        settings = {
          general = {
            after_sleep_cmd = "hyprctl dispatch dpms on";
            ignore_dbus_inhibit = false;
            lock_cmd = "hyprlock";
          };
          listener = [
            {
              timeout = 1800; # 30 mins
              on-timeout = "hyprlock";
            }
            {
              timeout = 1830; # 30.5 mins (30s after lock)
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on";
            }
          ];
        };
      };

      systemd.user.services.hypridle = {
        Unit = {
          PartOf = lib.mkForce ["hyprland-session.target"];
          After = lib.mkForce ["hyprland-session.target"];
        };
        Install.WantedBy = lib.mkForce ["hyprland-session.target"];
      };
    };
  };
}
