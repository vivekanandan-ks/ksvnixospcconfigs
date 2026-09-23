{
  inputs,
  self,
  ...
}: {
  flake-file.inputs = {
    mango.url = "github:mangowm/mango";
  };

  perSystem = {pkgs, ...}: {
    # Wrap mango so it always launches with /etc/profile loaded
    packages.ksvMango =
      (pkgs.symlinkJoin {
        name = "mango-wrapped";
        paths = [inputs.mango.packages.${pkgs.stdenv.hostPlatform.system}.mango];
        nativeBuildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/mango \
            --run "[ -f /etc/profile ] && . /etc/profile" \
            --run "[ -f /etc/profiles/per-user/\$USER/etc/profile.d/hm-session-vars.sh ] && . /etc/profiles/per-user/\$USER/etc/profile.d/hm-session-vars.sh"

          # Tag session as systemd-aware using X-NIXOS-SYSTEMD-AWARE.
          # Without this, NixOS's xsession-wrapper assumes Mango is a legacy non-systemd desktop
          # and prematurely triggers nixos-fake-graphical-session.target before Mango creates its
          # Wayland display socket. That causes xdg-desktop-portal to suffer repeated 15s timeouts
          # (freezing DMS for 40-50s) and graphical services (like Vicinae) to crash during login.
          if [ -d "$out/share/wayland-sessions" ]; then
            rm -f "$out/share/wayland-sessions/mango.desktop"
            sed 's/DesktopNames=mango;wlroots/DesktopNames=mango;wlroots;X-NIXOS-SYSTEMD-AWARE/' \
              "${inputs.mango.packages.${pkgs.stdenv.hostPlatform.system}.mango}/share/wayland-sessions/mango.desktop" \
              > "$out/share/wayland-sessions/mango.desktop"
          fi
        '';
        passthru = {
          providedSessions = ["mango"];
        };
      })
      // {
        providedSessions = ["mango"];
      };
  };

  flake = {
    # 1. NixOS System Configuration (wrapped mango with portals & ly entry)
    nixosModules.mangowc = {pkgs, ...}: {
      imports = [
        inputs.mango.nixosModules.mango
      ];

      programs.mango = {
        enable = true;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.ksvMango;
        addLoginEntry = true;
      };
    };

    # 2. Home Manager Configuration
    homeModules.nonDroid.mangowc = {
      config,
      lib,
      pkgs,
      ...
    }: {
      imports = [
        inputs.mango.hmModules.mango
      ];

      wayland.windowManager.mango = {
        enable = true;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.ksvMango;
        systemd = {
          enable = true;
          variables = ["--all"]; # Broadcasts WAYLAND_DISPLAY, DISPLAY, etc. to systemd/dbus
        };

        autostart_sh = lib.mkAfter ''
          systemctl --user restart xremap || true

          # Restart DMS so it connects to the fresh Mango IPC socket ($MANGO_INSTANCE_SIGNATURE)
          # and correctly filters running apps/windows by the active tag.
          # systemctl --user restart dms || true
        '';
      };

      # Systemd-managed clipboard history daemon bound to mango-session.target
      services.cliphist = lib.mkIf (config.wayland.windowManager.mango.enable or false) {
        enable = true;
        allowImages = true;
        systemdTargets = ["mango-session.target"];
      };
    };
  };
}
