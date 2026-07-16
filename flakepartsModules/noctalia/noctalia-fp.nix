{
  self,
  inputs,
  ...
}: {
  perSystem = {pkgs, ...}: {
    packages.ksvNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
      settings = pkgs.lib.recursiveUpdate
        (
          builtins.fromJSON (
            builtins.readFile ./ksv-noctalia.json
          )
        ).settings
        {
          general.avatarImage = "${./shoyohinata.png}";
          wallpaper.directory = "${../nixosfpModules/nixosResources/limine-images}";
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
          enabled = true;
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
}
