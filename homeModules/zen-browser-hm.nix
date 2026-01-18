{
  inputs,
  #config,
  #lib,
  pkgs,
  pkgs-unstable,
  #username,
  ...
}: {
  programs.zen-browser = {
    enable = true;
    nativeMessagingHosts = [pkgs-unstable.firefoxpwa];
    policies = {
      # check this for all policies:
      #https://mozilla.github.io/policy-templates/

      #AutofillAddressEnabled = true;
      #AutofillCreditCardEnabled = false;
      DisableAppUpdate = true;
      #DisableFeedbackCommands = true;
      #DisableFirefoxStudies = true;
      #DisablePocket = true;
      #DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      #NoDefaultBookmarks = true;
      OfferToSaveLogins = true;
      #EnableTrackingProtection = {
      #  Value = true;
      #  Locked = true;
      #  Cryptomining = true;
      #  Fingerprinting = true;
      #};
    };
    profiles.default = {
      search = {
        force = true; # Needed for nix to overwrite search settings on rebuild

        # https://github.com/nix-community/home-manager/blob/83bcb17377f0242376a327e742e9404e9a528647/modules/programs/firefox/profiles/search.nix#L211
        default = "google"; # Aliased to duckduckgo, see other aliases in the link above
        privateDefault = "ddg";

        engines = let
          nixSnowflakeIcon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        in {
          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = nixSnowflakeIcon;
            definedAliases = ["pkgs"];
          };
          "Nix Options" = {
            urls = [
              {
                template = "https://search.nixos.org/options";
                params = [
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = nixSnowflakeIcon;
            definedAliases = ["nop"];
          };
          "Home Manager Options" = {
            urls = [
              {
                template = "https://home-manager-options.extranix.com/";
                params = [
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                  {
                    name = "release";
                    value = "master"; # unstable
                  }
                ];
              }
            ];
            icon = nixSnowflakeIcon;
            definedAliases = ["hmop"];
          };
        };
      };

      extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
        # extensions name: https://nur.nix-community.org/repos/rycee/
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

      mods = [
        # https://zen-browser.app/mods/ 
        "642854b5-88b4-4c40-b256-e035532109df" # Transparent Zen
        "4596d8f9-f0b7-4aeb-aa92-851222dc1888" # Only Close On Hover
        "a6335949-4465-4b71-926c-4a52d34bc9c0" # Better Find Bar
        "2317fd93-c3ed-4f37-b55a-304c1816819e" # Audio Indicator Enhanced
        "f4866f39-cfd6-4498-ab92-54213b8279dc" # Animation plus
        "906c6915-5677-48ff-9bfc-096a02a72379" # Floating Status Bar
        "c5f7fb68-cc75-4df0-8b02-dc9ee13aa773" # Audio TabIcon Plus
        #"664c54f9-d97d-410b-a479-23dd8a08a628" # Better Tab Indicators
        "d8b79d4a-6cba-4495-9ff6-d6d30b0e94fe" # Better Active Tab
        "72f8f48d-86b9-4487-acea-eb4977b18f21" # Better CtrlTab Panel
        "f7c71d9a-bce2-420f-ae44-a64bd92975ab" # Better Unloaded Tabs
        "58649066-2b6f-4a5b-af6d-c3d21d16fc00" # Private Mode Highlighting
        "87196c08-8ca1-4848-b13b-7ea41ee830e7" # Tab Preview Enhanced
        "bc25808c-a012-4c0d-ad9a-aa86be616019" # sleek border
        "35f24f2c-b211-43e2-9fe4-2c3bc217d9f7" # Compact tabs title
        #"180d9426-a020-4bd7-98ec-63f957291119" # TitleBarButton UI Tweaks
        "8039de3b-72e1-41ea-83b3-5077cf0f98d1" # Trackpad Animation

      ];

      settings = {
        #"browser.tabs.warnOnClose" = true;
        #"browser.tabs.hoverPreview.enabled" = true;
        zen = {
          workspaces.continue-where-left-off = true;
          workspaces.natural-scroll = true;
          view.compact.hide-tabbar = true;
          view.compact.hide-toolbar = true;
          view.compact.animate-sidebar = true;
          welcome-screen.seen = true;
          urlbar.behavior = "float";
        };

        #"browser.download.panel.shown" = false;
        # Since this is a json value, it can be nixified and translated by home-manager;
        browser = {
          tabs.warnOnClose = false;
          tabs.hoverPreview.enabled = true;
          #download.panel.shown = false;
        };
        # Find all settings in about:config
      };

      bookmarks = {
        #force = true; # Required for nix to overwrite bookmarks on rebuild
        settings = [
          {
            name = "Nix sites";
            toolbar = true;
            bookmarks = [
              {
                name = "homepage";
                url = "https://nixos.org/";
              }
              {
                name = "wiki";
                tags = ["wiki" "nix"];
                url = "https://wiki.nixos.org/";
              }
            ];
          }
        ];
      };
    };
  };
}
