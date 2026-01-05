{
  lib,
  ...
}:

{
  # limine boot
  boot.loader = {
    limine = {
      enable = true;
      #style.wallpapers = lib.filesystem.listFilesRecursive ./nixosModules/nixosResources/limine-images ; # list of wallpaper paths
      style.wallpapers = lib.filesystem.listFilesRecursive ./../../nixosModules/nixosResources/limine-images ; # list of wallpaper paths
      #style.wallpaperStyle = "centered";
      
      extraEntries = ''
        /Windows
          protocol: efi
          path: uuid(1c135138-506a-45ed-8352-6455f45e9fea):/EFI/Microsoft/Boot/bootmgfw.efi
      '';
      

      extraConfig = ''
        remember_last_entry: yes
      '';
    };
  };
}