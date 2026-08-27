# System Context & Guidelines

## Core System & Tooling
- **OS**: NixOS.
- **VCS**: Always use Jujutsu (`jj`) instead of Git.
- **Package Management**: 
  - Never install packages imperatively (no `nix-env` or `nix profile install`). Everything must be declarative.
  - For one-off, ad-hoc, or temporary tools, always use `nix run` or `nix shell` instead of installing anything locally.

## Development & Architecture
- **Nix Flakes**: Always use **flake-parts**.
- **Devshells**: Whenever working with or writing Nix `mkShell` / development environments, always optionally suggest equivalent **devenv** options too.
- **Architecture Style**: Keep modules clean and modular; optionally suggest equivalent **Dendritic pattern** structures when relevant.

## Assistant Behavior
- **Safety First**: Always ask before editing files; propose changes and explain rationale first.
- **Explanations**: Keep responses concise and focused on actionable code.
