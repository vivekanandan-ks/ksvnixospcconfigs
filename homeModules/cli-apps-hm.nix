{
  #inputs,
  #config,
  lib,
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
  programs.micro = {
    enable = true;
    package = pkgs-unstable.micro;
    settings = {
      # Refer: zyedidia/micro/blob/master/runtime/help/options.md and https://forum.garudalinux.org/t/mastering-the-micro-text-editor/32889/14
      helpsplit = "vsplit";
      hlsearch = true;
      hltaberrors = true;
      savecursor = true;
      scrollbar = true;
      tabhighlight = true;
      #mkparents = true; # default false
      softwrap = true;

      autoclose = true; # automatically closes brackets, quotes, etc...
      comment = true; # provides automatic commenting for a number of languages # Simply place the cursor on the line and use the shortcut alt+/. The line will be commented according to the language used.
      linter = true; # provides extensible linting for many languages

      status = true; # provides some extensions to the status line (integration with Git and more).
      #statusformatr = "$(status.branch) | $(status.hash) | $(status.size)";
      diff = true;
      diffgutter = true;

    };
  };
  home.packages =
    let
      /*microPluginsRepoText = pkgs-unstable.writers.writeText "microPluginsRepo" ''
        sparques/micro-quoter
        priner/micro-aspell-plugin
        a11ce/micro-autofmt
        wakatime/micro-wakatime
        AndCake/micro-plugin-lsp # not added yet
        NicolaiSoeborg/manipulator-plugin
        terokarvinen/micro-jump
        terokarvinen/micro-run
        dmaluka/micro-detectindent
      '';*/

    in
    [
      pkgs-unstable.wl-clipboard # for micro editor external clipboard integration
      # shell script to auto download the plugins (yet to implement the correct symlinking to the micro plugins path)
      /*(pkgs-unstable.writers.writeNuBin
        # name
        "microPluginsAutoInstall"
        # other options
        {
          makeWrapperArgs = [
            "--prefix"
            "PATH"
            ":"
            "${lib.makeBinPath (
              with pkgs-unstable;
              [
                #pkgs-unstable.hello
                cat
                xargs
                git
              ]
            )}"
          ];
        }
        # script
        ''
          cd /home/ksvnixospc/Documents/ksvnixospcconfigs/homeModules/hmResources/microPlugins/
          cat ${microPluginsRepoText} | xargs -n 1 git clone

        ''
      )*/
    ];
  home.File.".config/micro/plug/" = {
    recursive = true;
    source = ./hmResources/microPlugins/plug ;
  };


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
