{self, ...}: {
  flake.nixosModules.limine = {
    config,
    lib,
    ...
  }: {
    # limine boot
    boot.loader = {
      limine = {
        enable = true;
        style.wallpapers = lib.filesystem.listFilesRecursive self.personas.ksv.currentWallpaperSet;
        # Restore Limine's default 50% neutral tint over wallpapers instead of Stylix's solid background
        style.graphicalTerminal.background = lib.mkForce null;

        extraEntries = lib.mkIf (config.networking.hostName == "deejunixospc") ''
          /Windows
            protocol: efi
            path: uuid(1c135138-506a-45ed-8352-6455f45e9fea):/EFI/Microsoft/Boot/bootmgfw.efi
        '';

        extraConfig = lib.mkIf (config.networking.hostName == "deejunixospc") ''
          remember_last_entry: yes
        '';
      };
    };
  };
}
