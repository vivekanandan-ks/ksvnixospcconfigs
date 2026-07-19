{...}: {
  flake = {
    homeModules.nonDroid.hypridle = {
      pkgs-unstable,
      ...
    }: {
      services.hypridle = {
        enable = true;
        package = pkgs-unstable.hypridle;
        settings = {
          general = {
            after_sleep_cmd = "hyprctl dispatch dpms on";
            ignore_dbus_inhibit = false;
            lock_cmd = "hyprlock";
          };
          listener = [
            {
              timeout = 300; # 5 mins
              on-timeout = "hyprlock";
            }
            {
              timeout = 330; # 5.5 mins (30s after lock)
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on";
            }
          ];
        };
      };
    };
  };
}
