_: {
  flake.homeModules.nonDroid.screenshot-tool = {
    config,
    pkgs-unstable,
    ...
  }: {
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

  flake.homeModules.nonDroid.xremap = {
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
            "grim -g \"$(slurp)\" - | satty --filename -"
          ];
          "Ctrl-Super-PRINT".launch = [
            "sh"
            "-c"
            "mkdir -p ~/Pictures/Screenshots && file=~/Pictures/Screenshots/screenshot_\$(date +%Y-%m-%d_%H-%M-%S).png && grim \"\$file\" && notify-send -a \"Screenshot\" \"Screenshot Saved\" \"\$file\""
          ];
        };
      }
    ];
  };
}
