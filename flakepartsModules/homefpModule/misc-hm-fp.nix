_: {
  # 1. Common CLI services (for both desktop and phone)
  flake.homeModules.common.misc = {pkgs-unstable, ...}: {
    services.tldr-update = {
      enable = true;
      package = pkgs-unstable.tldr;
      period = "weekly";
    };
  };

  # 2. Desktop GUI/Wayland services (for desktop only)
  flake.homeModules.nonDroid.misc = {pkgs-unstable, ...}: {
    services.wl-clip-persist = {
      enable = true;
      package = pkgs-unstable.wl-clip-persist;
    };
  };
}
