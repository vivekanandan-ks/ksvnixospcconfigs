{
  self,
  inputs,
  ...
}: {
  flake-file.inputs = {
    #noctalia = {
    #  url = "github:noctalia-dev/noctalia-shell";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    noctalia-legacy-v4-plugins = {
      url = "github:noctalia-dev/legacy-v4-plugins";
      flake = false;
    };
  };

  perSystem = {pkgs, ...}: {
    packages.ksvNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
      outOfStoreConfig = "/home/ksvnixospc/.config/noctalia-shell";
      settings =
        pkgs.lib.recursiveUpdate
        (
          builtins.fromJSON (
            builtins.readFile ./ksv-noctalia.json
          )
        )
        {
          general.avatarImage = "${./shoyohinata.png}";
          wallpaper.directory = "${./wallpaper}";
          wallpaper.useWallhaven = false;
          wallpaper.useOriginalImages = true;
          wallpaper.automationEnabled = true;
          wallpaper.randomIntervalSec = 300;
          wallpaper.showHiddenFiles = true;
        };

      preInstalledPlugins = {
        clipper = {
          enabled = true;
          src = "${inputs.noctalia-legacy-v4-plugins.outPath}/clipper";
        };
        catwalk = {
          enabled = true;
          src = "${inputs.noctalia-legacy-v4-plugins.outPath}/catwalk";
        };
        hot-corners = {
          enabled = true;
          src = "${inputs.noctalia-legacy-v4-plugins.outPath}/hot-corners";
        };
        netbird = {
          enabled = true;
          src = "${inputs.noctalia-legacy-v4-plugins.outPath}/netbird";
        };
        network-indicator = {
          enabled = true;
          src = "${inputs.noctalia-legacy-v4-plugins.outPath}/network-indicator";
        };
        plugin-manager = {
          enabled = true;
          src = "${inputs.noctalia-legacy-v4-plugins.outPath}/plugin-manager";
        };
        privacy-indicator = {
          enabled = false;
          src = "${inputs.noctalia-legacy-v4-plugins.outPath}/privacy-indicator";
        };
        screen-shot-and-record = {
          enabled = true;
          src = "${inputs.noctalia-legacy-v4-plugins.outPath}/screen-shot-and-record";
        };
        usb-drive-manager = {
          enabled = true;
          src = "${inputs.noctalia-legacy-v4-plugins.outPath}/usb-drive-manager";
        };
        workspace-overview = {
          enabled = true;
          src = "${inputs.noctalia-legacy-v4-plugins.outPath}/workspace-overview";
        };
        mpvpaper = {
          enabled = false;
          src = "${inputs.noctalia-legacy-v4-plugins.outPath}/mpvpaper";
        };
        video-wallpaper = {
          enabled = false;
          src = "${inputs.noctalia-legacy-v4-plugins.outPath}/video-wallpaper";
        };
      };
    };
  };

  flake = {
    homeModules.nonDroid.noctalia = {
      pkgs,
      lib,
      self,
      ...
    }: {
      systemd.user.services.noctalia = {
        Unit = {
          Description = "Noctalia Shell";
        };
        Service = {
          ExecStart = "${lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.ksvNoctalia}";
          Restart = "on-failure";
        };
      };
    };
  };

  /*
  Hot Corners Plugin Configuration Notes:
  - Top Left Command: `hyprctl dispatch overview:toggle`
  - Bottom Right: `hyprctl dispatch workspace empty`
  */
}
