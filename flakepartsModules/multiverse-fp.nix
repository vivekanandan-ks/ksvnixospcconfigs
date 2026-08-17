{inputs, ...}: {
  # Define the multiverse input for flake-file
  flake-file.inputs = {
    multiverse.url = "github:fzakaria/nixpkgs-multiverse";
  };

  # Auto-registered Home Manager module for the `mv` CLI registry
  flake.homeModules.common.multiverse-registry = {inputs, ...}: {
    nix.registry.mv.flake = inputs.multiverse;
  };

  # Configure per-system module arguments
  perSystem = {system, ...}: let
    mv = inputs.multiverse.lib.mkMultiverse {
      inherit system;
      config = {
        allowUnfree = true;
        nvidia.acceptLicense = true;
      };
      fastFallback = "eval"; # Seamless fallback for unfree packages
    };
    /*
      addLazyOverride = name: pkg:
      if builtins.isAttrs pkg && pkg ? eval
      then
        if builtins.elem name ["carapace" "zoxide" "starship"]
        then pkg.eval
        else let
          evalMeta = pkg.eval.meta or {};
        in
          pkg
          // {
            override = pkg.eval.override;
            overrideAttrs = pkg.eval.overrideAttrs;
            passthru = pkg.eval.passthru or {};
            meta = evalMeta // {outputsToInstall = ["out"];};
            shellPath = pkg.eval.shellPath or "/bin/${pkg.pname or "sh"}";
          }
      else pkg;

    # fastTip is enabled on x86_64-linux; non-x86_64 systems (like aarch64-linux Nix-on-Droid) fall back to mv.tip
    fastTip =
      if system == "x86_64-linux"
      then builtins.mapAttrs addLazyOverride mv.fast.tip
      else {};
    */
  in {
    _module.args = {
      inherit mv;
      pkgs = mv.tip;
      # 1. Unstable Native: For complex NixOS/HM modules, login shells, and services
      pkgs-unstable = mv.tip;

      # 2. Fast-Mode Unstable: 0 ms instant store paths + full nested sets for apps across the codebase
      # pkgs-mv-fast-tip =
      #   mv.tip
      #   // (
      #     if system == "x86_64-linux"
      #     then mv.fast.tip
      #     else {}
      #   );
      pkgs-mv-fast-tip = mv.tip;

      # 3. Stable Channel: Access official stable packages on-demand with zero flake inputs
      pkgs-stable = mv.at "26.05";
    };
  };
}
