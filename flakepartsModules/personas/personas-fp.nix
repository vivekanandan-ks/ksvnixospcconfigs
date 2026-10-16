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

      nip05 = {
        primary = "vivekanandanks@uid.ovh";
        alternatives = [
          "nixjoyer@uid.ovh"
          "ksvivekanandan@uid.ovh"
          "ksvivek@uid.ovh"
          "nixjoyerksv@uid.ovh"
        ];
      };

      relay = {
        pubkeyHex = "f98f3bd52b385d122176ddb6424642eadee4c26b19f1de7970da7cc27713ce03";
        npub = "npub1lx8nh4ft8pw3ygtkmkmyy3jzat0wfsntr8cau7tsmf7vyacnecps06shyk";
      };
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

    # --- Mesh Network Topologies ---
    network = {
      netbird = {
        hosts = {
          ksvnixospc = "100.75.134.39";
          deejunixospc = "100.75.157.43";
          akashnixospc = "100.75.5.254";
        };
      };
    };
  };
}
