{inputs, ...}: {
  flake-file.inputs.ksv-personal-artifacts = {
    url = "github:vivekanandan-ks/ksv-personal-artifacts";
    flake = false;
  };

  flake.personas.ksv = {
    # --- Identity & Display ---
    username = "ksvnixospc";
    personalName = "KSV"; # Visual / display purposes only
    email = "ksvdevksv@gmail.com";
    gitEmail = "ksvdevksv@gmail.com";
    gitUsername = "vivekanandan-ks";

    # --- Shell ---
    personalShell = pkg: pkg.nushell;

    # --- Visual Assets ---
    avatar = ./shoyohinata.png;
    wallpapers = "${inputs.ksv-personal-artifacts}/wallpapers"; # Root directory containing all wallpaper sets
    currentWallpaperSet = "${inputs.ksv-personal-artifacts}/wallpapers/andreasrochaWallpapers"; # Active wallpaper set

    # --- Typography / Fonts ---
    font = {
      monospace = {
        name = "JetBrainsMono Nerd Font";
        package = pkg: pkg.nerd-fonts.jetbrains-mono;
      };
      sizes = {
        applications = 10;
        terminal = 11;
        desktop = 9;
        # popups = 18;
      };
    };
  };
}
