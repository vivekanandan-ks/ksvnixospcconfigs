{
  inputs,
  #config,
  #pkgs,
  #pkgs-unstable,
  ...
}:

{

  imports = [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];

  /*
    services.flatpak.remotes = [
      {
        name = "flathub-beta";
        location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
      }
    ];
  */

  services.flatpak.packages = [

    "app.zen_browser.zen"
    #"org.kde.kdenlive"

    #{
    #  appId = "com.brave.Browser";
    #  origin = "flathub";
    #}

  ];

  #services.flatpak.update.onActivation = true;
  services.flatpak.update.auto = {
    enable = true;
    onCalendar = "weekly"; # Default value
  };

}
