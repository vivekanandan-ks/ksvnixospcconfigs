{
  inputs,
  ...
}: {
  flake-file.inputs = {
    ksv-cachyos-settings-nixos = {
      url = "github:vivekanandan-ks/ksv-cachyos-settings-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.nixosModules.ksv-cachyos-settings = _: {
    imports = [
      inputs.ksv-cachyos-settings-nixos.nixosModules.default
    ];

    cachyos.settings = {
      enable = true;
      enableGaming = false;
    };
  };
}
