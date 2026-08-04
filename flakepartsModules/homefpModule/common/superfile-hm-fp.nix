{...}: {
  flake.homeModules.common.superfile = {
    #inputs,
    #config,
    #lib,
    #pkgs,
    pkgs-unstable,
    ...
  }: {
    programs.superfile = {
      enable = true;
      package = pkgs-unstable.superfile;
      firstUseCheck = false;
      metadataPackage = pkgs-unstable.exiftool;
      zoxidePackage = pkgs-unstable.zoxide;
      settings = {
        transparent_background = true;
        theme = "catppuccin-mocha";

        dir_editor = "zeditor";
        show_panel_footer_info = true;
        file_panel_extra_columns = 3;
        nerdfont = true;
        show_select_icons = true;
        #enable_file_preview_border = true;
        ignore_missing_fields = true;
      };

    };
  };
}
