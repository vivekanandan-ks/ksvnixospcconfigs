This is my personal config, each step is taken towards a scalable way to maintain configs and keep aspects together and I am currently following dendritic pattern through flake-parts. All .nix file is a flake-parts module and imported recursively in an easy way thanks to vic's import-tree.

And the flake-file of this project is also crucial as it makes me group aspects in same file. Dont want something? Just move the file out of the import-tree folder (flakepartsModules in this case). No need to hardcode any path as everything is a top level flake-parts module. This way simplifies tons of things and reduce some config efforts debt later.

The configs are guardailed with treefmt(which inclused deadnix, statix, nixf-diagnose, alejandra formatting and formatting for other file formats too, etc), githooks(for some submodules protection, avoid symlinks, secrets leak, etc).

Treefmt give both a formatter and a checker and githooks give a checker.
So configured in a way that running

```bash
nix fmt
```

will format with treefmt and running

```bash
nix flake check
```

will do treefmt check and githook's check too along with the usual flake check.

So Finally the workflow for the configs will be like:

1.  nix run .#write-flake
2.  nix fmt
3.  nix flake check
4.  whatever command like nh os boot, nix develop etc etc

Also u can try the whole config without applying in ur nixos system, with this single command:

```bash
nix run .#nixosConfigurations.ksvnixospc.config.system.build.vm
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

Generating nixos-facter json file for each host:
https://github.com/nix-community/nixos-facter

```nu
sudo nix run nixpkgs#nixos-facter | save -f ksvnixospc.facter.json
```

```bash
sudo nix run nixpkgs#nixos-facter > ksvnixospc.facter.json
```
