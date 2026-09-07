_: {
  flake.homeModules.nonDroid.vscode-common-env = {pkgs-unstable, ...}: {
    home.packages = with pkgs-unstable; [
      #nixfmt
      alejandra
      nixd
      nil

      # vscode
      /*
      (vscode-with-extensions.override {

        vscode = vscode-package;

        vscodeExtensions = vscode-extnsns;
      })
      */
    ];

    home.sessionVariables = {
      NIXOS_OZONE_WL = "1"; # To use VS Code and other apps under Wayland
    };
  };
}
