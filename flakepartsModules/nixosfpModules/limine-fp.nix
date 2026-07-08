{...}: {
  flake.nixosModules.limine = {
    config,
    lib,
    ...
  }: {
    # limine boot
    boot.loader = {
      limine = {
        enable = true;
        style.wallpapers = lib.filesystem.listFilesRecursive ./nixosResources/limine-images;

        extraEntries = lib.mkIf (config.networking.hostName == "deejunixospc") ''
          /Windows
            protocol: efi
            path: uuid(1c135138-506a-45ed-8352-6455f45e9fea):/EFI/Microsoft/Boot/bootmgfw.efi
        '';

        extraConfig = ''
          remember_last_entry: yes
        '';
      };
    };
  };
}
