{
  inputs,
  lib,
  ...
}: let
  skillsDir = "${inputs.ponytail}/skills";
  # Dynamically discover all skill subdirectories from upstream
  upstreamSkillDirs = lib.filterAttrs (_: type: type == "directory") (builtins.readDir skillsDir);
in {
  # Dendritic input: flake-file will register this into flake.nix
  flake-file.inputs = {
    ponytail = {
      url = "github:dietrichgebert/ponytail";
      flake = false;
    };
  };

  # 1. Contributes upstream rule
  flake.aiContext = {
    PONYTAIL = "${inputs.ponytail}/AGENTS.md";
  };

  # 2. Dynamically maps every upstream skill folder into the shared pool
  flake.aiSkills = lib.mapAttrs (name: _: "${skillsDir}/${name}") upstreamSkillDirs;
}
