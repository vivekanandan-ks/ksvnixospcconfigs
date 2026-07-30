{
  self,
  inputs,
  ...
}: {

  flake = {
    homeModules.nonDroid.kitty = { pkgs, self, ... }: {
      programs.kitty = {
        enable = true;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.ksvKitty;
      };
    };
  };

  perSystem = {pkgs, pkgs-unstable, ...}: {
    packages.ksvKitty = inputs.wrapper-modules.wrappers.kitty.wrap {
      pkgs = pkgs-unstable;
      package = pkgs-unstable.kitty;

      settings = {
        hide_window_decorations = "yes";
        shell = "${pkgs-unstable.zellij}/bin/zellij";
      };

      extraConfig = ''
        # cursor
        #cursor_shape  block
        cursor_trail  3
        cursor_trail_decay  0.1 0.4
        #cursor_blink_interval 0
        #cursor_trail_start_threshold 0

        # window
        #background_opacity 0.7
        background_blur 1
        dynamic_background_opacity yes

        # terminal bell
        enable_audio_bell no
        visual_bell_duration 1
        window_alert_on_bell yes
        bell_on_tab "🔔 "
      '';
    };
  };
}
