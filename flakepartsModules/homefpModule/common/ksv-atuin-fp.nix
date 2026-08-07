{
  inputs,
  ...
}: {
  flake = {
    homeModules.common.atuin = {
      pkgs,
      self,
      ...
    }: {
      programs.atuin = {
        enable = true;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.ksvAtuin;
        enableNushellIntegration = true;
        enableFishIntegration = true;
        enableBashIntegration = true;
        flags = [
          "--disable-up-arrow"
        ];
      };
    };
  };

  perSystem = {pkgs-unstable, ...}: {
    packages.ksvAtuin = inputs.wrapper-modules.wrappers.atuin.wrap {
      pkgs = pkgs-unstable;
      package = pkgs-unstable.atuin;

      settings = {
        auto_sync = true;
        sync_frequency = "1m";
        sync.records = true;
        search_mode = "fuzzy";
        style = "auto";
        inline_height = 40; # default 40
        show_preview = true;
        history_filter = [
          #"^z"
          "^clear"
          "^exit"
        ];
        theme = {
          name = "marine"; # options are ""(default) or "autumn" or "marine"(good out of the three)
          debug = true;
        };
      };
    };
  };
}
