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

    # --- Nostr Identity ---
    nostr = {
      npub = "npub1a7lmem86sz35musrjfwt4j8mkg3rlrnvw7rhcm25deww8n5r8y3qh62zpr";
      pubkeyHex = "efbfbcecfa80a34df203925cbac8fbb2223f8e6c77877c6d546e5ce3ce833922";
    };

    # --- Shell ---
    personalShell = pkg: pkg.nushell;

    # --- Visual Assets ---
    avatar = ./shoyohinata.png;
    wallpapers = "${inputs.ksv-personal-artifacts}/wallpapers"; # Root directory containing all wallpaper sets
    currentWallpaperSet = "${inputs.ksv-personal-artifacts}/wallpapers/andreasrochaWallpapers"; # Active wallpaper set

    # --- Theming (Single Source of Truth) ---
    theme_polarity = "dark"; # "dark" | "light"

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
