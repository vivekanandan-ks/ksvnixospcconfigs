_: {
  flake.homeModules.common.nix-gh-token = {
    config,
    lib,
    ...
  }: {
    # --- Bash ---
    programs.bash.initExtra = lib.mkIf config.programs.bash.enable ''
      if command -v gh >/dev/null 2>&1; then
        _gh_token=$(gh auth token 2>/dev/null)
        if [ -n "$_gh_token" ]; then
          export NIX_CONFIG="extra-access-tokens = github.com=$_gh_token"
        fi
        unset _gh_token
      fi
    '';

    # --- Fish ---
    programs.fish.interactiveShellInit = lib.mkIf config.programs.fish.enable ''
      if type -q gh
        set -l _gh_token (gh auth token 2>/dev/null)
        if test -n "$_gh_token"
          set -gx NIX_CONFIG "extra-access-tokens = github.com=$_gh_token"
        end
      end
    '';

    # --- Nushell ---
    programs.nushell.extraEnv = lib.mkIf config.programs.nushell.enable ''
      if (which gh | is-not-empty) {
        let _gh_res = (do { ^gh auth token } | complete)
        if $_gh_res.exit_code == 0 and ($_gh_res.stdout | str trim | is-not-empty) {
          $env.NIX_CONFIG = $"extra-access-tokens = github.com=($_gh_res.stdout | str trim)"
        }
      }
    '';
  };
}
