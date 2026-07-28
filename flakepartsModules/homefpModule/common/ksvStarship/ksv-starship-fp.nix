{
  self,
  inputs,
  ...
}: {
  perSystem = {pkgs-unstable, ...}: {
    packages.ksvStarship = inputs.wrapper-modules.wrappers.starship.wrap {
      pkgs = pkgs-unstable;
      package = pkgs-unstable.starship;
      settings = builtins.fromTOML (
        builtins.readFile ./starship-themes/pastel-powerline.toml
      );
    };
  };

  flake = {
    homeModules.common.starship = { pkgs, self, ... }: {
      programs.starship = {
        enable = true;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.ksvStarship;
        enableNushellIntegration = true;
        enableFishIntegration = true;
        enableBashIntegration = true;
        #enableInteractive = false; #see HM option page before uncommenting
      };
    };
  };
}
