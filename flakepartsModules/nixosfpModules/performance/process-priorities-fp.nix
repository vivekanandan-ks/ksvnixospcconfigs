_: {
  # ─────────────────────────────────────────────────────────────────────────────
  # 1. NixOS System Configuration
  # Automatically imported across all hosts via `config.myCommonNixosModules`
  # ─────────────────────────────────────────────────────────────────────────────
  flake.nixosModules.process-priorities = _: {
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
