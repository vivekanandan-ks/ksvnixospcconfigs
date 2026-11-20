{
  lib,
  self,
  ...
}: {
  options.flake.aiContext = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.unspecified;
    default = {};
    description = "Shared AI guidelines, personas, and rule files contributed by AI modules.";
  };

  options.flake.aiSkills = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.unspecified;
    default = {};
    description = "Shared AI skills contributed by AI modules.";
  };

  # Aggregator: takes all contributed skills and maps them individually into agent skill folders
  config.flake.homeModules.common.ai-skills = {
    home.file = lib.mkMerge (
      lib.mapAttrsToList (name: path: {
        ".gemini/config/skills/${name}".source = path;
        ".agents/skills/${name}".source = path;
      }) (self.aiSkills or {})
    );
  };
}
