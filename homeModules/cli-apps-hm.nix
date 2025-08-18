{
  #inputs,
  #config,
  #lib,
  #pkgs,
  pkgs-unstable,
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
    
  };

  # nix helper
  programs.nh = {
    enable = true;
    package = pkgs-unstable.nh;
    clean = {
      enable = true;
      dates = "daily";
      extraArgs = "--keep 5 --keep-since 3d";
    };
  };

  # fastfetch
  programs.fastfetch = {
    enable = true;
    package = pkgs-unstable.fastfetch;
    settings = builtins.fromJSON (builtins.readFile ./hmResources/fastfetch-settings.json);
  };

  # micro - editor
  /*programs.micro = {
    enable = true;
    package = pkgs-unstable.micro;
    settings = {

    };
  };*/

  # git
  programs.git = {
    enable = true;
    package = pkgs-unstable.git;
    extraConfig = {
      user.name = "vivekanandan-ks";
      user.email = "ksvdevksv@gmail.com";
      init.defaultBranch = "main";
      #core.editor = "nano";
    };
  };

  # jujutsu
  /*
    programs.jujutsu = {
      enable = true;
      package = pkgs-unstable.jujutsu;
      settings = {
        user = {
          email = "ksvdevksv@gmail.com";
          name = "vivekanandan-ks";
        };
        #ui.editor = "micro";
        snapshot.max-new-file-size = "10MiB"; # https://github.com/jj-vcs/jj/blob/main/docs/config.md#maximum-size-for-new-files
      };
    };
  */

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
