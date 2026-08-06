{...}: {

  flake.nixosModules.auto-mount-drives = { ... }: {

    services.udisks2.enable = true;

    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if ((action.id == "org.freedesktop.udisks2.filesystem-mount-system" ||
             action.id == "org.freedesktop.udisks2.filesystem-mount") &&
            subject.isInGroup("users")) {
          return polkit.Result.YES;
        }
      });
    '';

  };


  flake.homeModules.nonDroid.auto-mount-drives = { ... }: {

    services.udiskie = {
      enable = true;
      automount = false;
      notify = true;
      tray = "auto";

      settings = {
        device_config = [
          {
            is_internal = true;
            is_systeminternal = false;
            automount = true;
          }
          {
            is_removable = true;
            automount = false;
          }
        ];
      };
    };

  };

}
