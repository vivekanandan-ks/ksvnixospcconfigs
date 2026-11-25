# DankMaterialShell (DMS) Configuration

This directory contains the modular, dendritic Home Manager configuration for **DankMaterialShell (DMS)** within the MangoWM Wayland desktop environment.

> [!IMPORTANT]
> **Schema Versioning (`configVersion`) Rules**:
>
> - **Settings Schema (`dms-settings-fp.nix`)**: Must stay locked to **`42`** (`SettingsData.settingsConfigVersion`).
> - **Session Schema (`dms-session.json`)**: Must stay locked to **`7`** (`SessionData.sessionConfigVersion`).
> - **Do not manually edit or increment `configVersion`**: Upstream DMS runs destructive migration routines on startup if `configVersion` is lower than expected (e.g., Migration 27 doubles all control center grid cell widths). Only update these version numbers when upstream DMS officially bumps its schema version after a `flake.lock` update.

---

## 📁 Directory Structure & Architecture

```
flakepartsModules/homefpModule/nonDroid/dms/
├── dms-README.md                 # This file: core architecture & versioning rules
├── dms-fp.nix                    # Wrapper derivation, session initialization & systemd service
├── dms-options-fp.nix            # Declares dms.extra* widget and package options
├── dms-settings-fp.nix           # 102 core scalar and complex settings (configVersion = 42)
├── dms-bars-fp.nix               # Bar configs with directional widget merging
├── dms-control-center-fp.nix     # Control Center grid layout sorted by (row, col)
├── dms-session.json              # State / position tracking (configVersion = 7)
├── dms-plugins-README.md         # Keybindings and descriptions for individual plugins
└── dms-plugins/                  # Modular plugins (battery, screenkey, bluetooth, etc.)
```

---

## 🧩 Dendritic Extension Pattern

Individual feature modules and plugins inject their own components without editing central files:

### 1. Bar Widgets

Bar widgets are merged with directional list appending in `dms-bars-fp.nix`:

- **Left / Center Widgets**: `baseWidgets ++ config.dms.extraLeftWidgets` (appends to the right).
- **Right Widgets**: `config.dms.extraRightWidgets ++ baseWidgets` (prepends to the left so edge widgets like clock and control center button stay pinned to the right).

### 2. Control Center Widgets

Widgets define their standard grid object `{ id, row, col, w, h }` in their plugin file:

```nix
dms.extraControlCenterWidgets = [
  {
    id = "plugin_screenkey";
    row = 4;
    col = 6;
    w = 2;
    h = 1;
    enabled = true;
  }
];
```

`dms-control-center-fp.nix` merges and sorts the final list strictly by `(row, col)` to ensure zero grid wrapping.

### 3. Extra Runtime Packages

Plugins declare their runtime CLI requirements using:

```nix
dms.extraPackages = [ pkgs.grim pkgs.slurp ];
```

These are automatically wrapped into DMS binary's `$PATH` via `dms-fp.nix`.
