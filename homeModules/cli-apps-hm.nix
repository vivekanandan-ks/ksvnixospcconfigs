{
  #inputs,
  config,
  #lib,
  #pkgs,
  pkgs-unstable,
  #isDroid ? false,
  ...
}:

{

  #btop
  programs.btop = {
    enable = true;
    package = pkgs-unstable.btop;
  };

  # bat # cat modern alternative
  programs.bat = {
    enable = true;
    package = pkgs-unstable.bat;
    extraPackages = with pkgs-unstable.bat-extras; [
      batman
    ];

  };

  # nix helper
  programs.nh = {
    enable = true;
    package = pkgs-unstable.nh;
    clean = {
      enable = true;
      dates = "daily";
      extraArgs = "--keep 3 --keep-since 3d";
    };
  };

  # fastfetch
  programs.fastfetch = {
    enable = true;
    package = pkgs-unstable.fastfetch;
    settings = builtins.fromJSON (builtins.readFile ./hmResources/fastfetch-settings.json);
  };

  # git
  programs.git = {
    enable = true;
    package = pkgs-unstable.git;
    settings = {
      user.name = "vivekanandan-ks";
      user.email = "ksvdevksv@gmail.com";
      init.defaultBranch = "main";
      #core.editor = "nano";
    };
  };

  # bluetuith
  programs.bluetuith = {
    enable = true;
    package = pkgs-unstable.bluetuith;
    settings = {
      #adapter = "hci0";
      receive-dir = "${config.home.homeDirectory}/Downloads/Bluetooth/";

      keybindings = {
        Menu = "Alt+m";
      };

      /*
        theme = {
          Adapter = "red";
        };
      */
    };
  };

  programs.gemini-cli = {
    enable = true;
    package = pkgs-unstable.gemini-cli;
  };

  /*programs.nix-index = {
    enable = true;
    package = pkgs-unstable.nix-index;
    enableBashIntegration = false;
    enableFishIntegration = false;
    enableZshIntegration = false;
    enableNushellIntegration = true;
  };*/

  /*programs.claude-code = {
    enable = !isDroid;
    package = pkgs-unstable.claude-code;
  };*/

  programs.opencode = {
    enable = true;
    package = pkgs-unstable.opencode;
    enableMcpIntegration = true;
  };

  /*programs.codex = {
    enable = true;
    package = pkgs-unstable.codex;
  };*/

  # jujutsu

  programs.jujutsu = {
    enable = true;
    package = pkgs-unstable.jujutsu;
    settings = {
      user = {
        email = "ksvdevksv@gmail.com";
        name = "vivekanandan-ks";
      };
      #ui.editor = "micro";
      snapshot.max-new-file-size = "30MiB"; # https://github.com/jj-vcs/jj/blob/main/docs/config.md#maximum-size-for-new-files
    };
  };

  /*
    # github
    programs.gh = {
      enable = true ;
      package = pkgs-unstable.gh;
      #gitCredentialHelper = {
        #enable = true ;
        #hosts = [];
      #};
    };
  */

}
