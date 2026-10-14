{
  inputs,
  lib,
  self,
  ...
}: {
  # ---------------------------------------------------------------------------
  # 1. Flake-File Input Declaration (Colocated in this module)
  # ---------------------------------------------------------------------------
  flake-file.inputs = {
    ngit = {
      url = "git+https://ngit.dev/ngit.git?ref=stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # ---------------------------------------------------------------------------
  # 2. Home Manager Configuration (Imported across all hosts via common)
  # ---------------------------------------------------------------------------
  flake.homeModules = lib.optionalAttrs (inputs ? ngit) {
    common.nostr-vcs = {
      lib,
      pkgs,
      ...
    }: let
      # Amber's native out-of-the-box active signer relays
      bunkerRelays = [
        "wss://relay.nip46.com"
        "wss://nrs.primal.net"
        "wss://bucket.coracle.social"
        "wss://auth.nostr1.com"
      ];

      # Dynamically format into "relay=wss://...&relay=wss://..."
      bunkerQuery = lib.concatStringsSep "&" (map (r: "relay=${r}") bunkerRelays);
    in {
      # A. Install ngit and git-remote-nostr helper
      home.packages = [
        inputs.ngit.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

      # B. Declarative Git Configuration
      programs.git = {
        includes = [
          { path = "~/.config/git/secrets.inc"; }
        ];

        settings = {
          nostr = {
            # Strictly restrict event publication to the 5 relays in maintainers.yaml
            repo-relay-only = true;

            # Keep bookmark/branch list clean from foreign draft PRs
            auto-pr-branches = false;

            # Master Identity (Amber on mobile, dynamically sourced from personas)
            npub = self.personas.ksv.nostr.npub;

            # Amber Remote Bunker URI (NIP-46 requires 64-character hex public key)
            bunker-uri = "bunker://${self.personas.ksv.nostr.pubkeyHex}?${bunkerQuery}";
          };
        };
      };

      # C. Automated activation hook to populate the host's FIPS caller ID (bunker-app-key)
      home.activation.fipsBunkerKey = lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ -r /var/lib/fips/fips.key ]; then
          $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p $HOME/.config/git
          $DRY_RUN_CMD ${pkgs.coreutils}/bin/install -m 0600 /dev/null $HOME/.config/git/secrets.inc
          if [ -z "$DRY_RUN_CMD" ]; then
            ${pkgs.coreutils}/bin/cat <<EOF > $HOME/.config/git/secrets.inc
[nostr]
	bunker-app-key = $(${pkgs.coreutils}/bin/cat /var/lib/fips/fips.key)
EOF
          fi
        fi
      '';

      # C. Declarative Jujutsu Settings & Aliases
      programs.jujutsu.settings = {
        git = {
          # Automatically fetch from both GitHub and Nostr in parallel
          fetch = ["origin" "nostr"];
        };

        aliases = {
          # 1. Primary Dual-Push: Pushes to both GitHub & Nostr (signs via Amber)
          push-all = ["git" "push" "--remote" "origin" "--remote" "nostr"];

          # 2. Targeted Pushes:
          # Push to GitHub only (when phone is offline or battery is dead)
          push-gh = ["git" "push" "--remote" "origin"];

          # Push to Nostr only (catches up Nostr once phone is back online)
          push-nostr = ["git" "push" "--remote" "nostr"];

          # 3. Dual-Fetch
          fetch-all = ["git" "fetch" "--all-remotes"];

          # 4. First-Class Nostr PR & Collaboration Commands
          pr = ["util" "exec" "--" "ngit" "send"];              # Propose a PR
          prs = ["util" "exec" "--" "ngit" "list"];             # List open PRs
          pr-co = ["util" "exec" "--" "ngit" "pr" "checkout"]; # Checkout a PR locally
          pr-merge = ["util" "exec" "--" "ngit" "pr" "merge"]; # Merge a PR

          # 5. Full access to any other ngit features
          ngit = ["util" "exec" "--" "ngit"];
        };
      };
    };
  };
}
