_: {
  flake.homeModules.nonDroid.zed-beautify = {
    programs.zed-editor.userSettings = {
      # Active Theme: Black base with vibrant pastel accents and frosted blur
      theme = "Catppuccin Espresso (Blur) [Light]";

      /*
      # Fine-grained panel overrides (uncomment if you wish to customize individual surfaces)
      "experimental.theme_overrides" = {
        "background.appearance" = "blurred";
        "editor.background" = "#1e1e2e";
        "panel.background" = "#18182590";
        "status_bar.background" = "#18182590";
        "title_bar.background" = "#18182590";
        "tab_bar.background" = "#18182590";
        "tab.active_background" = "#1e1e2eb0";
        "tab.inactive_background" = "#00000000";
        "surface.background" = "#18182590";
      };
      */
    };
  };
}
