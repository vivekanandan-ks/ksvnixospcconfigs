_: {
  flake.nixosModules.zram = _: {
    # Compressed swap in RAM (protects mechanical HDD from I/O thrashing)
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 50; # Allocates up to 50% of RAM as compressed space (~4 GB on an 8 GB system)
      priority = 100;     # High priority ensures fast RAM compression is used before any disk swap
    };

    # Lower swappiness to prevent the kernel from aggressively writing pages to disk
    boot.kernel.sysctl = {
      "vm.swappiness" = 10;
    };
  };
}
