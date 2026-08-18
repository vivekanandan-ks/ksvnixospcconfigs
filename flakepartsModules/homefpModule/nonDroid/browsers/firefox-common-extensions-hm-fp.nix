{
  lib,
  inputs,
  ...
}: {
  flake-file.inputs = {
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    /*
      firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    */
  };

  flake.homeModules.nonDroid.firefox-common-extensions = {pkgs, ...}: {
    options.myBrowser.firefox-common-extensions = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with inputs.nur.legacyPackages.${pkgs.stdenv.hostPlatform.system}.repos.rycee.firefox-addons; [
        ublock-origin
        proton-pass
        proton-vpn
        #catppuccin-mocha-mauve
        #tree-style-tab
        darkreader
        plasma-integration
        streetpass-for-mastodon
        fediact
        libredirect
        bionic-reader
      ];
      description = "Shared Firefox extensions for Zen and other browsers.";
    };
  };
}
