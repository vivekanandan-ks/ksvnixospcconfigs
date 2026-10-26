{inputs, ...}: {
  flake-file.inputs = {
    dux-files.url = "github:duxlabs-dev/dux-files";
  };

  flake.homeModules.nonDroid.dux-files = {lib, ...}: {
    imports = [
      inputs.dux-files.homeModules.dux-files
    ];

    programs.dux-files = {
      enable = true;

      # Background daemon for instant window loading
      systemd = {
        enable = true;
        target = "mango-session.target";
      };

      # Open & Save dialog portal for MangoWM
      portal = {
        enable = true;
        preferred = true;
        desktop = "mango";
      };

      settings = {
        defaultView = "grid";
        showHidden = true;
        foldersFirst = true;
        confirmTrash = true;
        searchHidden = true;
        networkThumbnails = true;
        showSystemPartitions = true;
        openLocationIn = "tab";
      };
    };

    # Set as default desktop file manager
    xdg.mimeApps.defaultApplications = {
      "inode/directory" = "dev.duxlabs.files.desktop";
    };

    wayland.windowManager.mango.settings = {
      # MangoWM Keybinding: Ctrl + Alt + E
      bind = lib.mkAfter [
        "CTRL+ALT, e, spawn, dfiles show"
      ];

      # Translucency + Frosted Blur matching the rest of the desktop (uncomment to enable)
      # window_rule = lib.mkAfter [
      #   "focused_opacity:0.90,unfocused_opacity:0.75,app_id:dev\\.duxlabs\\.files"
      # ];
    };
  };
}
