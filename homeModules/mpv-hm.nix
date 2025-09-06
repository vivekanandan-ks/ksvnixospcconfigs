{
  #inputs,
  config,
  #lib,
  #pkgs,
  pkgs-unstable,
  ...
}:

{

  programs.mpv = {
    enable = true;
    package = pkgs-unstable.mpv;
    /*
      package = pkgs-unstable.mpv-unwrapped.wrapper {
        #mpv = pkgs-unstable.mpv-unwrapped.override { vapoursynthSupport = true; };
        youtubeSupport = true;
      };
    */
    scripts = with pkgs-unstable.mpvScripts; [
      mpris # MPRIS plugin for mpv
      mpv-cheatsheet # mpv script for looking up keyboard shortcuts shortcut : ?
      webtorrent-mpv-hook # Adds a hook that allows mpv to stream torrents

      # eisa01 mpv scripts. refer: https://github.com/Eisa01/mpv-scripts
      eisa01.smart-copy-paste-2
      #eisa01.undoredo

      #modernz # Fully automatic subtitle downloading for the MPV media player
      #memo # Recent files menu for mpv
      #autosub # Fully automatic subtitle downloading for the MPV media playe
      #thumbfastr # High-performance on-the-fly thumbnailer for mpv
      #chapterskip # Automatically skips chapters based on title
      #sponsorblock-minimal # Minimal script to skip sponsored segments of YouTube videos
      #quality-menu # Userscript for MPV that allows you to change youtube video quality (ytdl-format) on the fly
      #mpv-notify-send # Lua script for mpv to send notifications with notify-send

    ];

    /*
      bindings = {
        l = "seek 20";
        h = "seek -20";
        "]" = "add speed 0.1";
        "[" = "add speed -0.1";
        j = "seek -4";
        k = "seek 4";
        K = "cycle sub";
        J = "cycle sub down";
        w = "add sub-pos -10"; # move subtitles up
        W = "add sub-pos -1"; # move subtitles up
        e = "add sub-pos +10"; # move subtitles down
        E = "add sub-pos +1"; # move subtitles down
        "=" = "add sub-scale +0.1";
        "-" = "add sub-scale -0.1";
      };
    */

    config = {
      # recommended mpv settings can be referenced here:
      # https://iamscum.wordpress.com/guides/videoplayback-guide/mpv-conf

      # Profile
      # high-quality - Profile which sets some quality settings (Recommended)
      # fast - Profile for really bad hardware
      #profile = "fast";

      # General
      fullscreen = true; # Always open the video player in full screen
      keep-open = true; # Don't close the player after finishing the video
      save-position-on-quit = true; # The last position of your video is saved when quitting mpv
      force-seekable = true; # Force seeking (if seeking doesn't work)
      cursor-autohide = 100; # Cursor hide in ms
      autocreate-playlist = "same"; # Generate a playlist from same files in the same directory

      # OSD
      #osc = "no"; # Disable the whole OSD (if you use an external one like uosc)
      #osd-level = 1; # Level of OSD, some GUIs might surpress mpv OSD, so you can add it back
      #osd-bar = "no"; # Don't show a huge volume box on screen when turning the volume up/down
      #border = "no"; # Disable the Windows border of mpv

      # Screenshot
      screenshot-sw = true; # Turns on software rendering for screenshots Faster, but might lack stuff like HDR
      screenshot-format = "png"; # Output format of screenshots
      screenshot-high-bit-depth = "yes"; # Same output bitdepth as the video. Set it "no" if you want to save disc space
      screenshot-png-compression = 1; # Compression of the PNG picture (1-9) Higher value means better compression, but takes more time
      screenshot-jpeg-quality = 100; # Quality of JPG pictures (0-100). Higher value means better quality
      screenshot-dir = "${config.xdg.userDirs.pictures}/mpvScreenshots"; # Output directory
      screenshot-template = "%f-%wH.%wM.%wS.%wT-#%#00n"; # Name format you want to save the pictures

      # Priority (Language priority)
      slang = "eng,en,en-en,en-orig,english";
      alang = "jp,jpn,japanese,en,eng,english";

      # Video
      # Video output driver
      # See: https://github.com/mpv-player/mpv/wiki/GPU-Next-vs-GPU
      #vo = "gpu-next";
      # Called API
      # Use "opengl" or "d3d11" (Windows only) if you have compatibility issues.
      #gpu-api = "vulkan";
      # Hardware decoding for whatever your CPU/GPU supports (e.g. 8bit h264 / 10bit h265)
      # Use "auto-safe" or "auto-copy-safe"
      # "Copy" methods are safer to use, but the performance difference is probably not as high and maybe not even worth over "no" (disabled).
      # Manual options:
      # Nvidia GPU: "nvdec"/"nvdec-copy" (Recommended)
      # Windows: "dxva2-copy" or "vulkan"/"vulkan-copy"
      # Linux: "vaapi"/"vaapi-copy" or "vulkan"/"vulkan-copy"
      # Else "no" and disable it
      #hwdec = "no";
      # Ignore cropping (if specified inside a .mkv file)
      #video-crop = "0x0+0+0";

      # Audio
      audio-delay = "+0.084";

      # Subs
      sub-visibility = "yes";
      demuxer-mkv-subtitle-preroll = true; # forces showing subtitles while seeking through the video
      sub-auto-exts = "srt,ass,txt";
      #Don't select subtitles with the same language as the audio
      #Using "forced" instead still selects it if marked as forced track
      subs-with-matching-audio = "no";
      #Subtitle blending in scenechanges (smoother effect)
      #The difference is noticeable if you use interpolation with a non divisible integer (like 24fps content on 60Hz)
      #Use "video" to render subtitles at the video resolution instead of screen resolution
      #Keep in mind that this won't work with crop
      blend-subtitles = "yes";
      sub-fix-timing = "yes"; # Fixes subtitle timing for gaps smaller than 210ms
      sub-auto = "fuzzy"; # "all" # Load external subtitles with (almost) the same name as the video
      #Overwriting subtitle styling for ASS/SSA subtitle
      #"no" disables all "sub-ass-*" options, while "yes" enables them
      #"scale" includes "sub-scale" while "forces" includes all "sub-*" options
      #"scale" is "yes" with "sub-scale" enabled and "force" will
      sub-ass-override = "scale";
      #Some settings fixing VOB/PGS subtitles (creating blur & changing yellow subs to gray)
      #sub-gauss = "1.0";
      #sub-gray = "yes";
      #sub-pos = 90;
      #sub-font-size = 40;
      #sub-border-size = 2;
      #sub-shadow-offset = 2;
      #sub-ass-line-spacing = 1;
      #sub-ass-hinting = "normal";
      #sub-gauss = "1.0";
      #sub-gray = true;
      #sub-use-margins = false;
      #sub-font-size = 45;
      #sub-scale-by-window = true;
      #sub-scale-with-window = false;



      #speed = 1;
      hwdec = true;

      ytdl-format = "bestvideo+bestaudio/best";
      #watch-later-options-clr = true; # Dont save settings like brightness

    };

    /*scriptOpts = {

      modernz = {
        window_top_bar = true;
        greenandgrumpy = true;
        jump_buttons = true;
        speed_button = true;
        ontop_button = true; # pin button
        chapter_skip_buttons = true;
        track_nextprev_buttons = true;
        #hover_effect_color = "#7F7F7F"; # 50% gray
        #seekbarfg_color = "#FFFFFF";
        #seekbarbg_color = "#7F7F7F"; # 50% gray
      };

    };*/

  };

}
