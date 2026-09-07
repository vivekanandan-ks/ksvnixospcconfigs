_: {
  flake.homeModules.nonDroid.zed-beautify = {
    programs.zed-editor.userSettings = {
      # Active Theme: Black base with vibrant pastel accents and frosted blur
      theme = "Catppuccin Espresso (Blur) [Light]";

      "experimental.theme_overrides" = {
        # Solid, distinct active tab
        "tab.active_background" = "#24273a";
        "tab.inactive_background" = "#00000000";
        "tab_bar.background" = "#00000000";
      };
    };
  };
}
