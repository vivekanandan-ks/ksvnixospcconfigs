{
  inputs,
  ...
}: {
  flake = {
    homeModules.nonDroid.mpv = {
      pkgs,
      self,
      ...
    }: {
      programs.mpv = {
        enable = true;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.ksvMpv;
      };
    };
  };

  perSystem = {pkgs-unstable, ...}: {
    packages.ksvMpv = inputs.wrapper-modules.wrappers.mpv.wrap {
      pkgs = pkgs-unstable;
      package = pkgs-unstable.mpv;
      "mpv.conf".path = ./mpv.conf;
      "mpv.input".path = ./input.conf;
      script = {
        mpris.path = pkgs-unstable.mpvScripts.mpris;
        #webtorrent-mpv-hook.path = pkgs-unstable.mpvScripts.webtorrent-mpv-hook;
        thumbfast.path = pkgs-unstable.mpvScripts.thumbfast;
        modernz = {
          path = pkgs-unstable.mpvScripts.modernz;
          opts = {
            icon_theme = "material";
            window_top_bar = true;
            greenandgrumpy = true;
            jump_buttons = true;
            speed_button = true;
            ontop_button = true;
            chapter_skip_buttons = true;
            track_nextprev_buttons = true;
            playlist_button = "yes";
            screenshot_button = "yes";
            bottomhover = "no";
            osc_on_seek = "yes";
            osc_on_start = "yes";
            force_seek_tooltip = "yes";
            hover_button_size = 120;
            title = "\${media-title}";
            cache_info = "yes";
            cache_info_speed = "yes";
          };
        };
      };
    };
  };
}
