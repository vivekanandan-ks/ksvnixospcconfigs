_: {
  # ─────────────────────────────────────────────────────────────────────────────
  # 1. NixOS System Configuration
  # Automatically imported across all hosts via `config.myCommonNixosModules`
  # ─────────────────────────────────────────────────────────────────────────────
  flake.nixosModules.process-priorities = _: {
    # --- Real-Time Audio & Video Permissions ---
    # Grants PipeWire & OBS real-time audio scheduling permissions without exposing
    # risky memlock or negative nice privileges to untrusted user processes.
    security.pam.loginLimits = [
      {
        domain = "@users";
        item = "rtprio";
        type = "-";
        value = "98";
      }
      {
        domain = "@audio";
        item = "rtprio";
        type = "-";
        value = "99";
      }
      {
        domain = "@audio";
        item = "nice";
        type = "-";
        value = "-11";
      }
    ];

    # --- Cgroups v2 Proportional Resource Distribution ---
    # Balanced 2:1 ratio (approx 66% user : 33% system) under 100% CPU contention.
    systemd = {
      slices = {
        user.sliceConfig.CPUWeight = 200; # 2x priority for interactive user session
        system.sliceConfig.CPUWeight = 100; # Baseline default weight for system daemons
      };
      user.slices = {
        app.sliceConfig.CPUWeight = 150; # GUI apps (Zen, OBS, Ghostty, Kitty)
        session.sliceConfig.CPUWeight = 100; # Mango compositor, Waybar, status bars
        background.sliceConfig.CPUWeight = 50; # Background indexing and user daemons
      };

      # Delegate cgroups v2 controllers so user slices can actually control CPU & I/O
      # (Matches CachyOS upstream usr/lib/systemd/system/user@.service.d/delegate.conf)
      services."user@".serviceConfig.Delegate = "cpu cpuset io memory pids";

      # Elevate file limits & fast shutdown timeouts (prevents 90s reboot hangs)
      settings.Manager = {
        DefaultLimitNOFILE = "2048:2097152";
        DefaultTimeoutStartSec = "15s";
        DefaultTimeoutStopSec = "10s";
      };
      user.settings.Manager = {
        DefaultLimitNOFILE = "2048:2097152";
      };
    };

    # --- Ananicy Auto-Nice Daemon & BORE Latency-Nice Tuning ---
    # Merges cleanly with `services.ananicy` declared in `chaotic-nyx-nixos-fp.nix`
    services.ananicy = {
      settings = {
        apply_latnice = true; # Unlocks CachyOS BORE latency sensitivity tags
        apply_cgroup = false; # Prevents cgroups v2 root task attachment warnings
        check_freq = 15; # Scans every 15s (CachyOS default) instead of 60s
      };

      extraTypes = [
        # Real-time priority for critical media capture and encoding
        {
          type = "UltraLowLatency_RT";
          nice = -11;
          latnice = -15;
          sched = "normal";
          ioclass = "realtime";
          ionice = 0;
          oom_score_adj = -500;
        }
        # Throttles compilers without pausing or freezing builds
        {
          type = "HeavyBuild_Throttle";
          sched = "batch"; # Regular CPU slices, but marked non-preempting
          nice = 15; # Yields CPU cycles smoothly to desktop apps
          ioclass = "best-effort"; # Steady disk I/O without starvation
          ionice = 7; # Lowest priority within best-effort
        }
      ];

      extraRules = [
        # Zen Browser & child Gecko processes (fixes the `zen-beta` rule blindspot)
        {
          name = "zen-beta";
          nice = -8;
          latnice = -12;
          ioclass = "best-effort";
          ionice = 1;
        }
        {
          name = "zen";
          nice = -8;
          latnice = -12;
          ioclass = "best-effort";
          ionice = 1;
        }
        {
          name = ".zen-beta-wrappe";
          nice = -8;
          latnice = -12;
          ioclass = "best-effort";
          ionice = 1;
        }

        # OBS Studio & Audio Capture Threads
        {
          name = "obs";
          type = "UltraLowLatency_RT";
        }
        {
          name = "obs-ffmpeg-mux";
          type = "UltraLowLatency_RT";
        }

        # Heavy compilation tools (keeps builds running steadily in background)
        {
          name = "cc1plus";
          type = "HeavyBuild_Throttle";
        }
        {
          name = "rustc";
          type = "HeavyBuild_Throttle";
        }
        {
          name = "ld.lld";
          type = "HeavyBuild_Throttle";
        }
        {
          name = "nix-daemon";
          type = "HeavyBuild_Throttle";
        }

        # Antigravity CLI background agent (yields CPU to interactive desktop apps under BORE)
        {
          name = "agy";
          sched = "batch";
          nice = 10;
          latnice = 10;
          ioclass = "best-effort";
          ionice = 7;
        }
      ];
    };

    # --- Udev Performance Rules ---
    # Verified against CachyOS (60-ioschedulers.rules, 50-sata.rules, 99-cpu-dma-latency.rules)
    services.udev.extraRules = ''
      # 1. Optimal I/O Schedulers per drive type:
      # - SATA SSDs / eMMC: mq-deadline (low CPU overhead)
      ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
      # - NVMe SSDs (akashnixospc & future hosts): kyber (ultra-fast latency bounded)
      ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="kyber"
      # - Rotational HDDs: bfq (fair queuing)
      ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"

      # 2. SATA Active Link Power Management: Max performance on AC
      ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", ATTR{link_power_management_supported}=="1", ATTR{link_power_management_policy}="max_performance"

      # 3. CPU DMA Latency Lock permissions (prevents deep C-state sleep drops in OBS/audio)
      DEVPATH=="/devices/virtual/misc/cpu_dma_latency", OWNER="root", GROUP="audio", MODE="0660"

      # 4. Real-time timer permissions for Audio & PipeWire
      KERNEL=="rtc0", GROUP="audio"
      KERNEL=="hpet", GROUP="audio"
    '';
  };

  # ─────────────────────────────────────────────────────────────────────────────
  # 2. Home Manager Configuration
  # Automatically included across all hosts via `self.homeModules.nonDroid`
  # ─────────────────────────────────────────────────────────────────────────────
  flake.homeModules.nonDroid.process-priorities = _: {
    programs.zen-browser.profiles.default.settings = {
      # Aligns tab content processes with 4 hardware threads, reducing context-switching
      "dom.ipc.processCount" = 4;
    };
  };
}
