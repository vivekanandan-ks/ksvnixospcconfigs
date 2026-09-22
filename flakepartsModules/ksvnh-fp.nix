{
  self,
  inputs,
  ...
}: {
  perSystem = {pkgs, ...}: let
    ksvnh = pkgs.writeShellScriptBin "ksvnh" ''
      set -euo pipefail

      # Universally trust this repo's flake settings for all ksvnh commands & nested child subprocesses
      export NIX_CONFIG="accept-flake-config = true"

      sync_jj_metadata() {
        if [[ -d .git || -d .jj ]] && command -v jj >/dev/null 2>&1; then
          local target has_changes cid desc clean_desc

          # Check if @ has real code changes (excluding .jj-info and automated flake sync files)
          has_changes=$(jj --no-pager diff -r @ 'all() ~ (.jj-info | flake.lock | flake.nix)' --summary 2>/dev/null || true)
          if [[ -z "$has_changes" ]]; then
            # No code changes in @ -> The build represents latest(@-)
            target=$(jj --no-pager log -r 'latest(@-)' --no-graph -T 'change_id.shortest(6)' 2>/dev/null || true)
            target="''${target:+latest(@-)}"
            target="''${target:-@}"
          else
            target="@"
          fi

          cid=$(jj --no-pager log -r "$target" --no-graph -T 'change_id.shortest(6) ++ if(conflict, ":conflict")' 2>/dev/null || true)
          if [[ -n "$cid" ]]; then
            desc=$(jj --no-pager log -r "$target" --no-graph -T 'description.first_line()' 2>/dev/null || true)
            clean_desc=$(echo "''${desc:-wip}" | sed 's/[()]/::/g; s/ /_/g; s/[^a-zA-Z0-9:_.-]//g; s/__*/_/g; s/::*/:/g; s/:_/:/g' | cut -c1-50 | sed 's/^[:_.-]*//; s/[:_.-]*$//')
            echo "jj:''${cid}--''${clean_desc}" > .jj-info
            return
          fi
        fi
        [[ -d .git || -d .jj ]] && : > .jj-info || true
      }

      # 1. Flake Check & Format: ksvnh -c
      if [[ "''${1:-}" =~ ^(-c|--check)$ ]]; then
        shift
        nix run .#write-flake
        sync_jj_metadata
        nix fmt
        exec nix flake check "$@"
      fi

      # 2. Flake Check (No Build) & Format: ksvnh -co
      if [[ "''${1:-}" =~ ^(-co|--co|--check-only)$ ]]; then
        shift
        nix run .#write-flake
        sync_jj_metadata
        nix fmt
        exec nix flake check --no-build "$@"
      fi

      # 3. Write Flake Only: ksvnh --wf
      if [[ "''${1:-}" == "--wf" ]]; then
        shift
        exec nix run .#write-flake "$@"
      fi

      # 4. VM: ksvnh --vm
      if [[ "''${1:-}" == "--vm" ]]; then
        shift
        nix run .#write-flake
        sync_jj_metadata
        exec nix run ".#nixosConfigurations.$(hostname).config.system.build.vm" "$@"
      fi

      # 5. Download & Install Size: -w (current), --uw (simulated update)
      if [[ "''${1:-}" =~ ^(-w|--weather|--uw)$ ]]; then
        LOCK_OPTS=()
        [[ "$1" == "--uw" ]] && LOCK_OPTS=(--recreate-lock-file --no-write-lock-file)
        shift
        sync_jj_metadata

        echo ":: Checking size statistics for $(hostname)..."
        output=$(nix build ".#nixosConfigurations.$(hostname).config.system.build.toplevel" --dry-run "''${LOCK_OPTS[@]}" 2>&1)
        echo "$output" | grep -E 'will be built|will be fetched' || echo "• System is up-to-date (0 download, 0 build needed)!"
        exit 0
      fi

      # 6. Garbage Collection & Store Optimisation
      if [[ "''${1:-}" == "--gc" ]]; then
        shift
        echo ":: Running fast-nix-gc..."
        exec fast-nix-gc "$@"
      fi

      if [[ "''${1:-}" =~ ^(--optimise|--optimize)$ ]]; then
        shift
        echo ":: Optimising Nix store..."
        exec nix store optimise "$@"
      fi

      if [[ "''${1:-}" == "--gco" ]]; then
        shift
        echo ":: Running fast-nix-gc..."
        fast-nix-gc "$@"
        echo ":: Optimising Nix store..."
        exec nix store optimise
      fi

      # 7. Flake Update: ksvnh -u <switch|boot|test|build|dry-activate>
      if [[ "''${1:-}" =~ ^(-u|--update)$ ]]; then
        shift
        nix run .#write-flake
        nix flake update
      fi

      # Always sync flake
      nix run .#write-flake

      # Sync Jujutsu metadata tag after update & write-flake, right before build
      sync_jj_metadata

      # 8. nh OS Action (explicit action required)
      if [[ $# -gt 0 ]]; then
        action="$1"
        shift
        exec nh os "$action" -a "$@"
      else
        echo "Usage: ksvnh [-u] <switch|boot|test|build|dry-activate> [flags...]   # nh os actions"
        echo "       ksvnh -c                                                        # format & flake check"
        echo "       ksvnh -co                                                       # format & flake check (no build)"
        echo "       ksvnh --wf                                                      # write-flake"
        echo "       ksvnh --vm                                                      # run in VM"
        echo "       ksvnh -w                                                        # current download & install size"
        echo "       ksvnh --uw                                                      # simulated update download & install size"
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
