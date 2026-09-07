_: {
  flake.nixosModules.zram-memory = _: {
    # 1. Compressed swap in RAM (ZRAM)
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 50; # Allocates up to 50% of RAM as compressed space
      priority = 100;     # High priority ensures fast RAM compression is used before any disk swap
    };
  };
}
