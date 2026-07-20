{
  lib,
  ...
}: {
  flake.homeModules.nonDroid.firefox-common-extensions = {
    inputs,
    pkgs,
    ...
  }: {
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
