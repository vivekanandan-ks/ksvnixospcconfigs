{
  inputs,
  self,
  ...
}: {
  flake-file.inputs = {
    mango = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  perSystem = {pkgs, ...}: {
    # Wrap mango so it always launches with /etc/profile loaded
    packages.ksvMango = (pkgs.symlinkJoin {
      name = "mango-wrapped";
      paths = [inputs.mango.packages.${pkgs.stdenv.hostPlatform.system}.mango];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/mango \
          --run "[ -f /etc/profile ] && . /etc/profile; unset SHLVL"
      '';
      passthru = {
        providedSessions = ["mango"];
      };
    }) // {
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

        # Environment variables are loaded by the package wrapper, and mango-session.target
        # is automatically triggered by systemd.enable, starting DMS, cliphist, and xremap.
        # autostart_sh = ''
        #   systemctl --user restart xremap || true
        # '';
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
