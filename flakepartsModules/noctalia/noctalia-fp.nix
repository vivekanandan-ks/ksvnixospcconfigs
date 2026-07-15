{
  self,
  inputs,
  ...
}: {
  perSystem = {pkgs, ...}: {
    packages.ksvNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
      settings =
        (
          builtins.fromJSON (
            builtins.readFile ./ksv-noctalia.json
          )
        ).settings;
    };
  };
}
