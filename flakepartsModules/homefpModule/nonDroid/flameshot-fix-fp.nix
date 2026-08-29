_: {
  flake = {
    homeModules.nonDroid.flameshot-fix = {lib, ...}: {
      # 1. Configure Flameshot service with proper session target dependencies & Wayland environment
      systemd.user.services.flameshot = {
        Unit = {
          Description = "Flameshot screenshot tool";
          After = lib.mkAfter [
            "mango-session.target"
            "graphical-session.target"
            "xdg-desktop-portal.service"
            "tray.target"
          ];
          PartOf = lib.mkAfter [
            "mango-session.target"
          ];
          Wants = lib.mkAfter [
            "xdg-desktop-portal.service"
            "xdg-desktop-portal-wlr.service"
          ];
        };
        Service = {
          Environment = [
            "QT_QPA_PLATFORM=wayland"
            "QT_QPA_PLATFORMTHEME=kde"
          ];
        };
        Install = {
          WantedBy = lib.mkForce [
            "mango-session.target"
          ];
        };
      };

      # 2. Automatically restart portals when Mango starts
      # This ensures xdg-desktop-portal-wlr detects WAYLAND_DISPLAY and exposes the Screenshot portal
      wayland.windowManager.mango.autostart_sh = lib.mkAfter ''
        # Restart portals so they pick up WAYLAND_DISPLAY and expose the wlroots Screenshot interface
        systemctl --user restart xdg-desktop-portal xdg-desktop-portal-wlr || true
      '';
    };
  };
}
