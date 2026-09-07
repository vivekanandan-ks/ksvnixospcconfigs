_: {
  flake.nixosModules.zram-memory = _: {
    # 1. Compressed swap in RAM (ZRAM)
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 50; # Allocates up to 50% of RAM as compressed space
      priority = 100;     # High priority ensures fast RAM compression is used before any disk swap
    };

    # 2. Official CachyOS memory & cache tuning
    # Verified against upstream CachyOS (70-cachyos-settings.conf & 30-zram.rules)
    boot.kernel.sysctl = {
      # CachyOS ZRAM swappiness profile
      "vm.swappiness" = 150;

      # Cuts decompression waste: reads 1 page (4KB) at a time without readahead
      "vm.page-cluster" = 0;

      # Keeps directory and inode caches hot in RAM (CachyOS default: 50, standard Linux: 100)
      "vm.vfs_cache_pressure" = 50;

      # Prevents kswapd from overreacting and causing swap storms
      "vm.watermark_boost_factor" = 0;

      # Smooths disk writes and prevents desktop freezes during heavy file writing
      "vm.dirty_bytes" = 268435456;          # 256 MB
      "vm.dirty_background_bytes" = 67108864; # 64 MB
      "vm.dirty_writeback_centisecs" = 1500;  # 15s writeback interval

      # Disables NMI watchdog timer to reduce CPU core interrupts and power draw
      "kernel.nmi_watchdog" = 0;

      # Expands network socket backlog for bursty WebRTC & streaming transfers
      "net.core.netdev_max_backlog" = 4096;

      # Prevents file descriptor exhaustion under multi-tab browsers & LSP servers
      "fs.file-max" = 2097152;

      # Quiets non-critical kernel messages on the virtual console
      "kernel.printk" = "3 3 3 3";
    };

    # 3. Transparent Hugepages (THP) Optimization
    # (Matches CachyOS upstream usr/lib/tmpfiles.d/thp.conf & thp-shrinker.conf)
    systemd.tmpfiles.rules = [
      # Prevents synchronous memory allocation stalls in browsers and compilers
      "w! /sys/kernel/mm/transparent_hugepage/defrag - - - - defer+madvise"
      # THP Shrinker (Kernel 6.12+): Splits hugepages where >80% of pages are empty,
      # preventing premature OOMs and RAM overprovisioning on 8-16 GB systems
      "w! /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none - - - - 409"
    ];
  };
}
