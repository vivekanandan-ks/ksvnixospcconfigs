This is my personal config, each step is taken towards a scalable way to maintain configs and keep aspects together and I am currently following dendritic pattern through flake-parts. All .nix file is a flake-parts module and imported recursively in an easy way thanks to vic's import-tree.

And the flake-file of this project is also crucial as it makes me group aspects in same file. Dont want something? Just move the file out of the import-tree folder (flakepartsModules in this case). No need to hardcode any path as everything is a top level flake-parts module. This way simplifies tons of things and reduce some config efforts debt later.

I have adopted nix multiverse project for this config. Feel free to DM me on migration help.
And with flake-file's help, it's possible to ditch the nixpkgs inputs url and replace it with mv generated rev. so your workflow should never do flake update and then run the command.
ur workflow is, update flake, run write-flake and then build command and then commit. This order is important

The configs are guardailed with treefmt(which inclused deadnix, statix, nixf-diagnose, alejandra formatting and formatting for other file formats too, etc), githooks(for some submodules protection, avoid symlinks, secrets leak, etc).

Treefmt give both a formatter and a checker and githooks give a checker.
So configured in a way that running

# Note:

Always use `--accept-flake-config` while running any nix commnads for this nixos system config because I have simplified the config to reuse same substituters for nixos and home manager etc

```bash
nix fmt --accept-flake-config
```

will format with treefmt and running

```bash
nix flake check --accept-flake-config
```

will do treefmt check and githook's check too along with the usual flake check.

So Finally the workflow for the configs will be like:

# Important:

DONT UPDATE THE FLAKE WITH PROGRAM?COMMANDS LIKE -u FLAG in nh or update flag in nixos-rebuild

```bash
0.  nix flake update --accept-flake-config
```

# important after flake update as inputs.nixpkgs in fetched dynamically using mv

```bash
1.  nix run .#write-flake --accept-flake-config
2.  nix fmt --accept-flake-config
3.  nix flake check --accept-flake-config
4.  whatever command like nh os boot, nix develop etc etc

# basically if u want to update the system , u would the following:
nix flake update --accept-flake-config ; nix run .#write-flake --accept-flake-config ; nh os boot -a /home/ksvnixospc/Documents/ksvnixospcconfigs#ksvnixospc --accept-flake-config
# nushell syntax above for bash u have to use && instead of ;
```

## `ksvnh` (KSV Nix Helper)

To automate and speed up everyday NixOS workflows, use `ksvnh` (available directly in your system packages and as `nix run .#ksvnh`):

### Equivalent Commands Reference

| Action                            | Long-Form Command                                                                                                                         | `ksvnh` Shortcut                |
| :-------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------- | :------------------------------ |
| **Update & Rebuild**              | `nix flake update --accept-flake-config ; nix run .#write-flake --accept-flake-config ; nh os <boot\|switch\|test> --accept-flake-config` | `ksvnh -u <boot\|switch\|test>` |
| **Rebuild System**                | `nix run .#write-flake --accept-flake-config ; nh os <boot\|switch\|test> --accept-flake-config`                                          | `ksvnh <boot\|switch\|test>`    |
| **Format & Check**                | `nix run .#write-flake --accept-flake-config ; nix fmt --accept-flake-config ; nix flake check --accept-flake-config`                     | `ksvnh -c`                      |
| **Sync Flake Only**               | `nix run .#write-flake --accept-flake-config`                                                                                             | `ksvnh --wf`                    |
| **Check Download & Install Size** | `nix build ... --dry-run --accept-flake-config`                                                                                           | `ksvnh -w`                      |
| **Simulated Update Size**         | `nix build ... --recreate-lock-file --no-write-lock-file --dry-run --accept-flake-config`                                                 | `ksvnh --uw`                    |
| **Test in VM**                    | `nix run .#nixosConfigurations.$(hostname).config.system.build.vm --accept-flake-config`                                                  | `ksvnh --vm`                    |
| **Fast Garbage Collection**       | `fast-nix-gc`                                                                                                                             | `ksvnh --gc`                    |
| **Store Optimisation**            | `nix store optimise --accept-flake-config`                                                                                                | `ksvnh --optimise`              |
| **GC + Optimise**                 | `fast-nix-gc && nix store optimise --accept-flake-config`                                                                                 | `ksvnh --gco`                   |
| **Ephemeral Run**                 | `nix run .#ksvnh -- [flags...]`                                                                                                           | `nix run .#ksvnh -- -c`         |

### Passthrough Flags Examples

Any additional `nh` or `nix` flags are passed directly down:

```bash
ksvnh switch --ask                # Ask for confirmation before activation
ksvnh switch --dry-run            # Dry activation / test build
ksvnh -u boot -- --show-trace     # Pass trace flag to nix
ksvnh --gc --older-than 7d        # Pass flags directly to fast-nix-gc
```

Also u can try the whole config without applying in ur nixos system, with this single command:

```bash
nix run .#nixosConfigurations.ksvnixospc.config.system.build.vm --accept-flake-config

```

This config also have custom pre configured packages of mine:
can also get the below list by running:

```bash
nix eval --json .#packages.x86_64-linux --apply 'builtins.attrNames'
```

1. ksvNoctalia
2. ksvJujutsu
3. ksvGit
4. ksvFastfetch
5. ksvBtop
6. ksvMpv
7. ksvHelix
8. ksvAtuin
9. ksvSpicetify
10. ksvnh

Generating nixos-facter json file for each host:
https://github.com/nix-community/nixos-facter

```nu
sudo nix run nixpkgs#nixos-facter | save -f ksvnixospc.facter.json
```

```bash
sudo nix run nixpkgs#nixos-facter > ksvnixospc.facter.json
```
