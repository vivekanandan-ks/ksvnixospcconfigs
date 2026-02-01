{
  inputs,
  #config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}: {
  programs.vicinae = {
    enable = true;
    package = pkgs-unstable.vicinae;
    /*package = pkgs-unstable.vicinae.overrideAttrs (oldAttrs: {
      postInstall =
        (oldAttrs.postInstall or "")
        + ''
          substituteInPlace $out/share/systemd/user/vicinae.service \
            --replace "ExecStart=vicinae" "ExecStart=$out/bin/vicinae"
        '';
    });*/
    systemd.enable = true;
    settings = {
      window = {
        csd = true;
        opacity = 0.85;
        blur = true;
        rounding = 10;
      };
    };

    extensions = with inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}; [
      # https://docs.vicinae.com/nixos#configuring-with-home-manager
      bluetooth
      nix
      power-profile
      #chromium-boookmarks
      process-manager
      fuzzy-files
      kde-system-settings
      brotab
      vscode-recents
      wifi-commander
      #systemd
      player-pilot

      #(config.lib.vicinae.mkRayCastExtension {
      #  # https://www.raycast.com/vimtor/wikipedia
      #  name = "Wikipedia";
      #  sha256 = "sha256-hNYZhjM7qkW4FbHm/Tne4TWVPuQRIKUbKKXcTICpH7w=";
      #  rev = "b8c8fcd7ebd441a5452b396923f2a40e879565ba";
      #})
    ];
  };

  # Override the systemd service to fix the executable path

  /*systemd.user.services.vicinae = {
    Unit = {
      Description = "Vicinae Launcher Daemon";
      Documentation = "https://docs.vicinae.com";
      After = [ "graphical-session.target" ];
      Requires = [ "dbus.socket" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = lib.mkForce "${pkgs-unstable.vicinae}/bin/vicinae server --replace";
      Restart = "always";
      RestartSec = 60;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };*/

}
