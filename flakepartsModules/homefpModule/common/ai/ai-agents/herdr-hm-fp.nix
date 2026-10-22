_: {
  flake.homeModules.common.herdr = {
    # inputs,
    # config,
    # lib,
    # pkgs,
    pkgs-unstable,
    ...
  }: {
    programs.herdr = {
      enable = true;
      package = pkgs-unstable.herdr;

      # Merges declared Nix settings into a writable config.toml,
      # allowing live adjustments from Herdr UI/CLI to persist.
      mutableSettings = true;

      settings = {
        terminal = {
          kitty_graphics = true; # Render images via Kitty graphics protocol
          new_cwd = "follow"; # New panes/tabs inherit the current directory
        };

        ui = {
          # Visuals & Layout
          accent = "#89b4fa"; # Accent color for active borders/highlights
          hide_tab_bar_when_single_tab = false; # Always show tab bar even with one tab
          show_agent_labels_on_pane_borders = true; # Display agent name badge on pane borders
          status_indicators = "symbols"; # Explicit glyph symbols for agent states
          tab_bar_right = ["zoom" "hostname"]; # Status info on the right side of tab bar
          pane_scrollbars = true; # Draw interactive scrollbars beside panes
          window_title = true; # Sync terminal window title with active space
          copy_on_select = true; # Copy mouse selections to clipboard automatically

          # Notifications & Alerts
          sound = {
            enabled = true; # Audio cues when background agents finish or ask for input
          };

          toast = {
            delivery = "system"; # Trigger OS desktop notifications via notify-send / D-Bus
          };
        };

        # Optional direct number shortcuts (uncomment if you want Alt+1..9 jumping)
        # keys = {
        #   indexed = {
        #     workspaces = "alt";
        #     agents = "alt";
        #   };
        # };

        session = {
          resume_agents_on_restore = true; # Automatically resume agents when restoring sessions
        };

        update = {
          version_check = false; # Nix handles package updates
          manifest_check = true; # Keep agent definitions up-to-date
        };
      };
    };
  };
}
