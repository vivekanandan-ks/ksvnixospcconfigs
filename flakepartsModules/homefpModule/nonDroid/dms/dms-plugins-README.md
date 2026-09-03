# DankMaterialShell (DMS) Configuration & Plugin Keybindings

This directory houses the declarative configuration for **DankMaterialShell (DMS)**, custom bars, and modular DMS plugins within the MangoWM Wayland desktop environment.

---

## ⌨️ DMS & Plugin Keybindings

| Shortcut                  | Action / Trigger                  | Plugin / Component          | Notes                                                      |
| :------------------------ | :-------------------------------- | :-------------------------- | :--------------------------------------------------------- |
| **`SUPER + Space`**       | Toggle Spotlight / App Launcher   | **DMS Core**                | Opens centered launcher (Supports `\tab` for browser tabs) |
| **`SUPER + grave` (`~`)** | Toggle Scratchpad Picker          | **`scratchpadHelper`**      | Visual window switcher & previews for MangoWM scratchpads  |
| **`SUPER + c`**           | Toggle DankCalendar               | **`dankcalendar` / `dcal`** | Toggles calendar window (`dcalUpcoming` on bar)            |
| **`SUPER + ALT + b`**     | Toggle Battery Charge Limit       | **`batteryChargeControl`**  | Toggles 60% conservation mode vs 100% full charge          |
| **`SUPER + ALT + c`**     | Toggle Screen Capture Toolbar     | **`screenCaptureToolbar`**  | Floating pill toolbar with photo, video, and audio capture |
| **`SUPER + ALT + k`**     | Toggle Screenkey Overlay          | **`screenkey`**             | On-screen visualizer for keyboard shortcuts & mouse clicks |
| **`SUPER + SHIFT + K`**   | Toggle Virtual Keyboard           | **`virtualKeyboard`**       | On-screen touch/mouse keyboard typing through `ydotool`    |
| **`SUPER + SHIFT + R`**   | Toggle Screen Recording (Portal)  | **`screenRecorderLH`**      | Opens Wayland Portal dialog to record screen or window     |
| **`SUPER + ALT + R`**     | Toggle Screen Recording (Portal)  | **`screenRecorderLH`**      | Alternative binding for screen recording                   |
| **`SUPER + w`**           | Cycle / Toggle Wallpaper Carousel | **`wallpaperCarousel`**     | Rotates through wallpaper sets                             |
| **`CTRL + ALT + Delete`** | Toggle Power Menu                 | **DMS Core**                | System power actions (Shutdown, Reboot, Lock, Suspend)     |

### 🔍 Spotlight / Launcher Triggers (`SUPER + Space`)

- **`\tab <query>`**: Searches all open browser tabs across Zen Browser and Firefox using `tabsLauncher`.

---

## 📊 Bars & Layout

### 1. Main Bar (Top)

Defined in `dms-settings.json`. Hosts:

- **Left**: `runningApps` (Icon Only), `workspaceSwitcher`, `layout`, `music`.
- **Center**: `capsLockIndicator`.
- **Right**: `networkIndicator`, `cpuUsage`, `memUsage`, `batteryPlus`, `usbManager`, `simpleAudioControl`, `clock`.

### 2. Bottom Plugin Bar

Defined in `dms-bottom-bar-fp.nix`:

- **Left Section**:
  - **`focusedWindow`**: Application indicator in **Full Mode** (`[Icon] App Name • Window Title`).
  - **`barDropdown`**: Collapsible panel for modular system widgets.
  - **`scratchpadHelper`**: Visual MangoWM scratchpad indicator and picker.
  - **`ambientSound`**: Ambient focus sound generator with 24 audio loops (Right-click to mute).
- **Center Section**:
  - **`cpuCoreLoad`**: Real-time per-core CPU load bars via native `DgopService`.
  - **`materialPlayer`**: Centralized music playback widget and album/track info.
  - **`storageMonitor`**: Total disk usage and partition mount/unmount controller via `udisks2`.
- **Right Section**:
  - **`dankCleaner`**: One-click junk scan, disk analyzer, and Docker prune tool.
  - **`dnsSwitcher`**: Active DNS provider monitor and quick-switcher via NetworkManager.
  - **`caffeineRedesigned`**: Screen wake and idle inhibitor (5m/15m/30m/1h/2h/Infinite).
  - **`screenRecorderLH`**: Interactive recording pill showing duration and stop/pause controls.
  - **`virtualKeyboard`**: Quick-toggle button to show/hide the on-screen virtual keyboard.

---

## 🎛️ Control Center Widgets

Configured in `dms-settings.json` under `controlCenterWidgets`:

- **Row 1**: `wifi` (50%), `bluetooth` (50%)
- **Row 2**: `brightnessSlider` (50%), `darkMode` (25%), `nightMode` (25%)
- **Row 3**: `audioOutput` (50%), `audioInput` (50%)
- **Row 4**: `idleInhibitor` (25%), `doNotDisturb` (25%), `battery` (25%), `plugin_screenkey` (25%)
- **Row 5**: `diskUsage` (25%), `plugin_batteryChargeControl` (25%), `plugin_dankKDEConnect` (25%), `plugin_takeABreak` (25%)

---

## 🧩 Background Daemons & Passive Plugins

<!-- - **`musicTheme`**: Dynamically retints system theme colors (GTK, Qt, terminals) from currently playing album art via Matugen; automatically reverts to wallpaper colors when music stops. -->
- **`takeABreak`**: Scheduled 20-20-20 eye breaks and long rest reminders with pre-warning toasts and fullscreen break overlays (with smart gaming/fullscreen app suppression).
- **`scratchpadHelper`**: Caches scratchpad window states and previews for MangoWM.
- **`batteryOSD`**: Renders an animated Material You fluid wave popup whenever the charger is connected/disconnected or battery level reaches low threshold.
- **`dankBatteryAlerts`**: System notifications for battery warning (50%) and critical (30%) states.
- **`batteryChargeControl`**: Battery threshold management integrated into Control Center.

---

## 📦 Runtime Dependencies (`dmsExtraPackages`)

Dependencies are managed through the centralized `dmsExtraPackages` option defined in `dms-options-fp.nix`:

- Each plugin file declares its required packages:
  - `scratchpadHelper`: `pkgs.grim`
  - `ambientSound`: `pkgs.socat` (alongside `pkgs.mpv`)
  - `storageMonitor`: `pkgs.udisks2`
  - `screenRecorderLH`: `pkgs.gpu-screen-recorder`, `pkgs.slurp`, `pkgs.ffmpeg`, `pkgs.libnotify`
  - `screenCaptureToolbar`: `pkgs.slurp`, `pkgs.grim`, `pkgs.gpu-screen-recorder`
  - `screenkey`: `pkgs.evtest`, `pkgs.libinput`
- `dms-fp.nix` wraps the DMS binary's `$PATH` with all aggregated packages.
- **`virtualKeyboard`**: Managed via its own self-contained NixOS module (`programs.ydotool.enable = true`), where NixOS automatically starts `ydotoold`, creates the user group, and exports `YDOTOOL_SOCKET = "/run/ydotoold/socket"` system-wide.
