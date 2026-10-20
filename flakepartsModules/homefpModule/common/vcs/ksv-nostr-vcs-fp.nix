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
  # 2. NixOS Configuration (Automatically imported across all hosts via common-hosts-fp)
  # ---------------------------------------------------------------------------
  flake.nixosModules.nostr-vcs = {
    config,
    username,
    ...
  }: let
    bunkerSecretName = "nostr_bunker_uri_${config.networking.hostName}";
  in {
    sops.secrets.${bunkerSecretName} = {
      owner = username;
      group = "users";
      mode = "0400";
    };

    sops.templates."git-secrets.inc" = {
      content = ''
        [nostr]
        	bunker-app-key = ${config.sops.placeholder."fips_key_${config.networking.hostName}"}
        	bunker-uri = ${config.sops.placeholder.${bunkerSecretName}}
      '';
      owner = username;
      group = "users";
      mode = "0400";
    };
  };

  # ---------------------------------------------------------------------------
  # 3. Home Manager Configuration (Imported across all hosts via common)
  # ---------------------------------------------------------------------------
  flake.homeModules = lib.optionalAttrs (inputs ? ngit) {
    common.nostr-vcs = {
      pkgs,
      ...
    }: {
      # A. Install ngit and git-remote-nostr helper
      home.packages = [
        inputs.ngit.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

      # B. Declarative Git Configuration (Directly includes in-memory SOPS rendered secret)
      programs.git = {
        includes = [
          { path = "/run/secrets/rendered/git-secrets.inc"; }
        ];

        settings = {
          nostr = {
            # Strictly restrict event publication to the 5 relays in maintainers.yaml
            repo-relay-only = true;

            # Keep bookmark/branch list clean from foreign draft PRs
            auto-pr-branches = false;

            # Master Identity (Amber on mobile, dynamically sourced from personas)
            npub = self.personas.ksv.nostr.npub;
          };
        };
      };

      # C. Declarative Jujutsu Settings & Aliases
      programs.jujutsu.settings = {
        git = {
          # Automatically fetch from both Nostr (origin) and GitHub in parallel
          fetch = ["origin" "github"];

          # Automatically push to both Nostr (origin) and GitHub in parallel on bare `jj git push`
          push = ["origin" "github"];
        };

        aliases = {
          # 1. Primary Dual-Push: Pushes to both Nostr & GitHub
          push-all = ["git" "push" "--remote" "origin" "--remote" "github"];

          # 2. Targeted Pushes:
          # Push to Nostr only (primary decentralized forge)
          push-nostr = ["git" "push" "--remote" "origin"];

          # Push to GitHub only (mirror / fallback when phone is offline)
          push-gh = ["git" "push" "--remote" "github"];

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
