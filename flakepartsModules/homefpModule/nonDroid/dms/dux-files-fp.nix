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
        blurEnabled = true;
        floatingWindowTransparency = 0.50;
        floatingWindowForegroundLayers = true;
        floatingWindowForegroundTransparency = 0.75;
      };
    };

    # Set as default desktop file manager & default media handlers
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "dev.duxlabs.files.desktop";

        # Video -> VLC
        "video/mp4" = "vlc.desktop";
        "video/mkv" = "vlc.desktop";
        "video/x-matroska" = "vlc.desktop";
        "video/webm" = "vlc.desktop";
        "video/quicktime" = "vlc.desktop";
        "video/x-msvideo" = "vlc.desktop";
        "video/avi" = "vlc.desktop";
        "video/x-ms-wmv" = "vlc.desktop";
        "video/x-ms-asf" = "vlc.desktop";
        "video/x-flv" = "vlc.desktop";
        "video/flv" = "vlc.desktop";
        "video/mpeg" = "vlc.desktop";
        "video/x-mpeg" = "vlc.desktop";
        "video/x-mpeg2" = "vlc.desktop";
        "video/mp2t" = "vlc.desktop";
        "video/3gp" = "vlc.desktop";
        "video/3gpp" = "vlc.desktop";
        "video/3gpp2" = "vlc.desktop";
        "video/ogg" = "vlc.desktop";
        "video/x-ogm" = "vlc.desktop";
        "video/x-ogm+ogg" = "vlc.desktop";
        "video/x-theora" = "vlc.desktop";
        "video/x-theora+ogg" = "vlc.desktop";
        "video/divx" = "vlc.desktop";
        "video/vnd.divx" = "vlc.desktop";

        # Audio -> MPV
        "audio/mp3" = "mpv.desktop";
        "audio/mpeg" = "mpv.desktop";
        "audio/x-mpeg" = "mpv.desktop";
        "audio/x-mp3" = "mpv.desktop";
        "audio/mp4" = "mpv.desktop";
        "audio/m4a" = "mpv.desktop";
        "audio/x-m4a" = "mpv.desktop";
        "audio/flac" = "mpv.desktop";
        "audio/x-flac" = "mpv.desktop";
        "audio/wav" = "mpv.desktop";
        "audio/x-wav" = "mpv.desktop";
        "audio/x-pn-wav" = "mpv.desktop";
        "audio/ogg" = "mpv.desktop";
        "audio/x-ogg" = "mpv.desktop";
        "audio/vorbis" = "mpv.desktop";
        "audio/x-vorbis" = "mpv.desktop";
        "audio/x-vorbis+ogg" = "mpv.desktop";
        "audio/opus" = "mpv.desktop";
        "audio/aac" = "mpv.desktop";
        "audio/x-aac" = "mpv.desktop";
        "audio/webm" = "mpv.desktop";
        "audio/x-matroska" = "mpv.desktop";
        "audio/x-ms-wma" = "mpv.desktop";
        "audio/x-ms-wax" = "mpv.desktop";
        "audio/vnd.rn-realaudio" = "mpv.desktop";
        "audio/x-pn-realaudio" = "mpv.desktop";
        "audio/x-realaudio" = "mpv.desktop";
        "audio/x-ape" = "mpv.desktop";
        "audio/x-wavpack" = "mpv.desktop";
        "audio/x-tta" = "mpv.desktop";
        "audio/basic" = "mpv.desktop";
        "audio/midi" = "mpv.desktop";
        "audio/x-aiff" = "mpv.desktop";
        "audio/mpegurl" = "mpv.desktop";
        "audio/x-mpegurl" = "mpv.desktop";

        # Images -> Gwenview
        "image/jpeg" = "org.kde.gwenview.desktop";
        "image/png" = "org.kde.gwenview.desktop";
        "image/gif" = "org.kde.gwenview.desktop";
        "image/webp" = "org.kde.gwenview.desktop";
        "image/x-webp" = "org.kde.gwenview.desktop";
        "image/avif" = "org.kde.gwenview.desktop";
        "image/heif" = "org.kde.gwenview.desktop";
        "image/jxl" = "org.kde.gwenview.desktop";
        "image/bmp" = "org.kde.gwenview.desktop";
        "image/tiff" = "org.kde.gwenview.desktop";
        "image/svg+xml" = "org.kde.gwenview.desktop";
        "image/svg+xml-compressed" = "org.kde.gwenview.desktop";
        "image/x-ico" = "org.kde.gwenview.desktop";
        "image/x-icns" = "org.kde.gwenview.desktop";
        "image/x-xcf" = "org.kde.gwenview.desktop";
        "image/x-tga" = "org.kde.gwenview.desktop";
        "image/x-eps" = "org.kde.gwenview.desktop";
        "image/x-psd" = "org.kde.gwenview.desktop";
      };
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
