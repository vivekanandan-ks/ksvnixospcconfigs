_: {
  flake.homeModules.nonDroid.kdenlive = {pkgs-unstable, ...}: {
    home.packages = with pkgs-unstable; [
      kdePackages.kdenlive
      mediainfo
      frei0r
      glaxnimate
    ];

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "application/x-kdenlive" = ["org.kde.kdenlive.desktop"];
      };
    };
  };
}
