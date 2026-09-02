# DankMaterialShell (DMS) Configuration & Plugin Keybindings

This directory houses the declarative configuration for **DankMaterialShell (DMS)**, custom bars, and modular DMS plugins within the MangoWM Wayland desktop environment.

---

## ⌨️ DMS & Plugin Keybindings

| Shortcut | Action / Trigger | Plugin / Component | Notes |
| :--- | :--- | :--- | :--- |
| **`SUPER + Space`** | Toggle Spotlight / App Launcher | **DMS Core** | Opens the centered searchable app & action launcher |
| **`SUPER + w`** | Cycle / Toggle Wallpaper Carousel | **`wallpaperCarousel`** | Rotates through wallpaper sets |
| **`CTRL + ALT + Delete`** | Toggle Power Menu | **DMS Core** | System power actions (Shutdown, Reboot, Lock, Suspend) |
| **`SUPER + ALT + k`** | Toggle Screenkey Overlay | **`screenkey`** | On-screen visualizer for keyboard shortcuts & mouse clicks |
| **`SUPER + SHIFT + R`** | Toggle Screen Recording (Portal) | **`screenRecorderLH`** | Opens Wayland Portal dialog to record any screen or window |
| **`SUPER + ALT + R`** | Toggle Screen Recording (Portal) | **`screenRecorderLH`** | Alternative binding for screen recording |
| **`SUPER + ALT + c`** | Toggle Screen Capture Toolbar | **`screenCaptureToolbar`** | Floating pill toolbar with photo, video, and audio capture |
| **`SUPER + SHIFT + K`** | Toggle Virtual Keyboard | **`virtualKeyboard`** | On-screen touch/mouse keyboard typing through `ydotool` |

---

## 📊 Bars & Layout

### 1. Main Bar (Top)
Defined in `dms-settings.json`. Hosts workspace switcher, window title, system indicators, audio controls, battery, and clock.

### 2. Bottom Plugin Bar
Defined in `dms-bottom-bar-fp.nix`:
* **Left Section**:
  * **`barDropdown`**: Collapsible button that drops down a panel containing nested media widgets (`mediaControlPlus`, `materialPlayer`).
* **Center Section**: Empty (for clean aesthetics).
* **Right Section**:
  * **`screenRecorderLH`**: Interactive recording pill / status indicator showing active recording duration and stop/pause controls.
  * **`virtualKeyboard`**: Quick-toggle button to show/hide the on-screen virtual keyboard.

---

## 🧩 Background Daemons & Passive Plugins

* **`batteryOSD`**: Renders an animated Material You fluid wave popup whenever the charger is connected/disconnected or battery level reaches low threshold.
* **`dankBatteryAlerts`**: System notifications for battery warning (50%) and critical (30%) states.
* **`batteryChargeControl`**: Battery threshold management integrated into Control Center.

---

## 📦 Runtime Dependencies (`dmsExtraPackages`)

Dependencies are managed through the centralized `dmsExtraPackages` option defined in `dms-options-fp.nix`:
* Each plugin file simply declares:
  ```nix
  dmsExtraPackages = [ pkgs.someDependency ];
  ```
* `dms-fp.nix` wraps the DMS binary's `$PATH` with all aggregated packages.
* **`virtualKeyboard`**: Managed via its own self-contained NixOS module (`programs.ydotool.enable = true`) with socket pointing to `/run/ydotoold/ydotoold.socket`.
