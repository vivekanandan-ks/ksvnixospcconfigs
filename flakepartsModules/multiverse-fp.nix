{inputs, ...}: {
  # Define the multiverse input for flake-file
  flake-file.inputs = {
    multiverse.url = "github:fzakaria/nixpkgs-multiverse";
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
  in {
    _module.args = {
      inherit mv;
      # Fast mode for top-level packages (right side wins), with fallback for nested sets like kdePackages
      pkgs-unstable = mv.tip // fastTip;
    };
  };
}
