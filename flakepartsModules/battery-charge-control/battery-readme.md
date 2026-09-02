# Universal Battery Charge Control

A unified, hardware-agnostic battery charge limiting and health protection module for all hosts (`deejunixospc`, `ksvnixospc`, `akashnixospc`).

---

## 1. What This Provides

1. **Hardware Abstraction Across All Hosts**:
   - **Lenovo IdeaPad** (e.g. `deejunixospc`): Controls the Embedded Controller (EC) conservation mode via `/sys/bus/platform/drivers/ideapad_acpi/*/conservation_mode` (toggles between 60% cap and 100% full charge).
   - **Standard Linux sysfs Laptops** (ThinkPad, ASUS, Dell, Framework, etc.): Controls `/sys/class/power_supply/BAT*/charge_control_end_threshold` (toggles between 80% cap and 100% full charge) and sets hysteresis on `charge_control_start_threshold` where supported.
   - **Desktops / VMs**: Cleanly identifies that no battery hardware exists without errors.
2. **Passwordless Control**:
   - Automated `udev` rules apply `0666` permissions to battery threshold sysfs files on boot and hardware events. You can toggle thresholds from scripts, UI, or keybindings without `sudo` password prompts.
3. **Interactive Toggle & Desktop Notifications**:
   - Desktop toasts via `notify-send` with battery status icons (`battery-charging`, `battery-full`).
4. **MangoWM Keybinding**:
   - `SUPER + ALT + b` toggles between limited charging and 100% full charge instantly.
5. **DMS (Dank Material Shell) Bar / Control Center Button**:
   - Live status display and 1-click toggling via the `DankActions` plugin.

---

## 2. Commands & Outcomes

The `battery-limit` command is available in your shell:

| Command | Action | Desktop Notification |
| :--- | :--- | :--- |
| `battery-limit` or `battery-limit toggle` | Flips current state: if currently capped, switches to 100%; if currently 100%, switches to cap (60% on IdeaPad, 80% on standard sysfs). | 🔔 Yes ("Limit Active" or "Full Charge Enabled") |
| `battery-limit on` | Force enables protection (60% on IdeaPad, 80% on standard sysfs). | 🔔 Yes ("Limit Active") |
| `battery-limit off` | Force disables protection (charges to 100%). | 🔔 Yes ("Full Charge Enabled") |
| `battery-limit <number>` | Sets custom stop threshold percentage (e.g. `battery-limit 85`). On IdeaPads, `< 100` enables conservation mode (60%). | 🔔 Yes ("Limit Active") |
| `battery-limit status` (or `-s`) | Prints detailed diagnostic info of all detected batteries, thresholds, and modes. | 🔕 No (terminal stdout only) |
| `battery-limit --short` (or `-q`) | Returns a single line for status bars/widgets: `60% 🛡️`, `80% 🛡️`, `100% ⚡`, or `N/A`. | 🔕 No (terminal stdout only) |

---

## 3. DMS (Dank Material Shell) Control Center Integration

A dedicated DMS Control Center tile is configured in `dms-settings.json` under `controlCenterWidgets`:

### Last Row Layout in Control Center
```json
[
  { "id": "diskUsage", "width": 50 },
  { "id": "plugin_batteryChargeControl", "width": 25 },
  { "id": "plugin_dankKDEConnect", "width": 25 }
]
```
- **Storage (`diskUsage`)**: 50% width
- **Battery Limit (`plugin_batteryChargeControl`)**: 25% width
- **Phone Connect (`plugin_dankKDEConnect`)**: 25% width (enabled)

### Behavior & Features
- **Visual Status**: Displays `battery_saver` icon and lights up with the Material theme primary accent color when battery cap is active (`60% 🛡️` / `80% 🛡️`). Shows `battery_charging_full` when 100% full charging is enabled.
- **1-Click Toggle**: Clicking the tile instantly toggles the limit and shows a desktop toast notification.
- **Auto-Sync**: Automatically syncs state every 10 seconds or when triggered via the `SUPER + ALT + b` keyboard shortcut or terminal.

---

## 4. Keybinding (MangoWM)

A shortcut is registered in MangoWM:

```
SUPER + ALT + b -> battery-limit toggle
```

Pressing this key combo toggles the battery cap and displays a desktop toast immediately.

---

## 5. File Location & Flake Integration

- **System Module**: [battery-charge-control-fp.nix](file:///home/ksvnixospc/Documents/ksvnixospcconfigs/flakepartsModules/battery-charge-control/battery-charge-control-fp.nix)
  - Provides the `battery-limit` CLI binary, `libnotify`, udev rules, and MangoWM keyboard shortcut.
  - Automatically imported for all NixOS hosts via `myCommonNixosModules` in `common-hosts-fp.nix`.
- **DMS Plugin**: [dms-plugin-battery-charge-control-fp.nix](file:///home/ksvnixospc/Documents/ksvnixospcconfigs/flakepartsModules/homefpModule/nonDroid/dms/dms-plugins/dms-plugin-battery-charge-control-fp.nix)
  - Placed under `dms-plugins/` alongside other DMS plugins.
  - Declares `programs.dank-material-shell.plugins.batteryChargeControl` pointing to `./dms-battery-charge-control`.
