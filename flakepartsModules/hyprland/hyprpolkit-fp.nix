{...}: {
  flake = {
    homeModules.nonDroid.hyprpolkit = {
      pkgs-unstable,
      lib,
      ...
    }: {
      services.hyprpolkitagent = {
        enable = true;
        package = pkgs-unstable.hyprpolkitagent;
      };

      systemd.user.services.hyprpolkitagent = {
        Unit = {
          PartOf = lib.mkForce [ "hyprland-session.target" ];
          After = lib.mkForce [ "hyprland-session.target" ];
        };
        Install.WantedBy = lib.mkForce [ "hyprland-session.target" ];
      };
    };
  };
}
