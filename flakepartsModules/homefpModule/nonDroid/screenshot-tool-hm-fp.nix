_: {
  flake.homeModules.nonDroid.screenshot-tool = {
    config,
    lib,
    pkgs-unstable,
    ...
  }: {
    options.myScreenshotCmds = {
      regionCmd = lib.mkOption {
        type = lib.types.str;
        default = "sh -c 'file=/tmp/ss.png; grim \"$file\" && G=$(slurp) && [ -n \"$G\" ] && magick \"$file\" -crop \"$G\" +repage \"$file\" && satty --filename \"$file\"'";
        description = "Command for interactive frozen region screenshot to Satty";
      };
      fullCmd = lib.mkOption {
        type = lib.types.str;
        default = "sh -c 'mkdir -p ~/Pictures/Screenshots && file=~/Pictures/Screenshots/screenshot_\$(date +%Y-%m-%d_%H-%M-%S).png && grim \"\$file\" && notify-send -a \"Screenshot\" \"Screenshot Saved\" \"\$file\"'";
        description = "Command for instant full-screen screenshot saved to Pictures/Screenshots";
      };
    };

    config = {
      # 1. Install all Wayland screenshot & recording tools globally
      home.packages = with pkgs-unstable; [
        grim
        slurp
        satty
        wl-clipboard
        imagemagick
        tesseract
        wf-recorder
        jq
      ];

      # 2. Configure Satty settings & output directory
      programs.satty = {
        enable = true;
        package = pkgs-unstable.satty;
        settings = {
          general = {
            output-filename = "${config.xdg.userDirs.pictures}/sattyScreenshots/satty-%Y-%m-%d_%H:%M:%S.png";
            save-after-copy = true;
          };
        };
      };
    };
  };

  flake.homeModules.nonDroid.xremap = {
    config,
    lib,
    ...
  }: {
    services.xremap.config.keymap = lib.mkAfter [
      {
        name = "Screenshot shortcuts";
        remap = {
          "Ctrl-PRINT".launch = [
            "sh"
            "-c"
            config.myScreenshotCmds.regionCmd
          ];
          "Ctrl-Super-PRINT".launch = [
            "sh"
            "-c"
            config.myScreenshotCmds.fullCmd
          ];
        };
      }
    ];
  };
}
