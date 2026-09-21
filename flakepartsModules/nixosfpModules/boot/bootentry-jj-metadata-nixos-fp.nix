{self, ...}: {
  flake.nixosModules.bootentry-jj-metadata = {lib, ...}: {
    system.nixos.tags = let
      infoFile = self + "/.jj-info";
      tag =
        if builtins.pathExists infoFile
        then lib.trim (builtins.readFile infoFile)
        else "";
    in
      lib.optional (tag != "") tag;
  };
}
