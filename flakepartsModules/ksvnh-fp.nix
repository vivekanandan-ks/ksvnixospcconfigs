{
  self,
  inputs,
  ...
}: {
  perSystem = {pkgs, ...}: let
    ksvnh = pkgs.writeShellScriptBin "ksvnh" ''
      set -euo pipefail

      # 1. Flake Check & Format: ksvnh -c
      if [[ "''${1:-}" =~ ^(-c|--check)$ ]]; then
        shift
        nix run .#write-flake --accept-flake-config
        nix fmt --accept-flake-config
        exec nix flake check --accept-flake-config "$@"
      fi

      # 2. Write Flake Only: ksvnh --wf
      if [[ "''${1:-}" == "--wf" ]]; then
        shift
        exec nix run .#write-flake --accept-flake-config "$@"
      fi

      # 3. VM: ksvnh --vm
      if [[ "''${1:-}" == "--vm" ]]; then
        shift
        exec nix run ".#nixosConfigurations.$(hostname).config.system.build.vm" --accept-flake-config "$@"
      fi

      # 4. Binary Cache Weather & Build Size: ksvnh -w
      if [[ "''${1:-}" =~ ^(-w|--weather)$ ]]; then
        shift
        echo ":: Checking binary cache & build statistics for $(hostname)..."
        output=$(nix build ".#nixosConfigurations.$(hostname).config.system.build.toplevel" --dry-run --accept-flake-config 2>&1)
        built=$(echo "$output" | grep -oE '[0-9]+ derivations? will be built' || true)
        fetched=$(echo "$output" | grep -oE '[0-9]+ paths? will be fetched \([^)]+\)' || true)

        if [[ -n "$built" || -n "$fetched" ]]; then
          [[ -n "$built" ]] && echo "• Build:   $built"
          [[ -n "$fetched" ]] && echo "• Fetch:   $fetched"
        else
          echo "• System is already up-to-date (0 download, 0 build needed)!"
        fi
        exit 0
      fi

      # 5. Garbage Collection & Store Optimisation
      if [[ "''${1:-}" == "--gc" ]]; then
        shift
        echo ":: Running fast-nix-gc..."
        exec fast-nix-gc "$@"
      fi

      if [[ "''${1:-}" =~ ^(--optimise|--optimize)$ ]]; then
        shift
        echo ":: Optimising Nix store..."
        exec nix store optimise --accept-flake-config "$@"
      fi

      if [[ "''${1:-}" == "--gco" ]]; then
        shift
        echo ":: Running fast-nix-gc..."
        fast-nix-gc "$@"
        echo ":: Optimising Nix store..."
        exec nix store optimise --accept-flake-config
      fi

      # 6. Flake Update: ksvnh -u <switch|boot|test|build|dry-activate>
      if [[ "''${1:-}" =~ ^(-u|--update)$ ]]; then
        shift
        nix flake update --accept-flake-config
      fi

      # Always sync flake
      nix run .#write-flake --accept-flake-config

      # 7. nh OS Action (explicit action required)
      if [[ $# -gt 0 ]]; then
        action="$1"
        shift
        exec nh os "$action" --accept-flake-config "$@"
      else
        echo "Usage: ksvnh [-u] <switch|boot|test|build|dry-activate> [flags...]   # nh os actions"
        echo "       ksvnh -c                                                        # format & flake check"
        echo "       ksvnh --wf                                                      # write-flake"
        echo "       ksvnh --vm                                                      # run in VM"
        echo "       ksvnh -w                                                        # download & install size"
        echo "       ksvnh --gc | --optimise | --gco                                 # cleanup & optimise"
        exit 1
      fi
    '';
  in {
    packages.ksvnh = ksvnh;

    apps.ksvnh = {
      type = "app";
      program = "${ksvnh}/bin/ksvnh";
    };
  };

  # Automatically adds ksvnh and fast-nix-gc to system packages
  flake.nixosModules.ksvnh = {pkgs, ...}: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.ksvnh
      inputs.fast-nix-gc.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
