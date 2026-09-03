# Mango Virtual Monitor & Streaming Workspace

This module provides an isolated virtual display (`HEADLESS-1`) and a live zero-latency floating mirror (`wl-mirror`) to enable screen sharing, presenting, or recording without exposing private workspaces.

---

## 1. How It Works

```
┌──────────────────────────────┐        ┌──────────────────────────────┐
│ Physical Display (eDP-1)     │        │ Virtual Output (HEADLESS-1)  │
│ 1366x768                     │        │ 1920x1080 (Off-screen)       │
│                              │        │                              │
│  ┌────────────────────────┐  │        │  ┌───────────┐ ┌───────────┐ │
│  │ Private Work           │  │        │  │ Browser   │ │ Terminal  │ │
│  │ (Code, Notes, Chat)    │  │        │  │           │ │           │ │
│  └────────────────────────┘  │        │  └───────────┘ └───────────┘ │
│  ┌────────────────────────┐  │        │   (Tiled by Mango engine)    │
│  │ wl-mirror (Floating)   │  │        └──────────────┬───────────────┘
│  │ [Pinned across tags]   │  │                       │
│  └────────────────────────┘  │                       ▼
└──────────────────────────────┘               OBS / Discord / WebRTC
                                                (Select HEADLESS-1)
```

1. **MangoWM** spawns an off-screen virtual display (`HEADLESS-1`) via `create_virtual_output`.
2. Windows pushed to `HEADLESS-1` are dynamically tiled and managed by MangoWM's layout engine.
3. **`wl-mirror`** opens a floating `640x360` picture-in-picture window on your physical display, showing a live mirror of what is happening on the virtual monitor with mouse cursor feedback.
4. **Pinned across all tags (`isglobal:1`)**: The mirror window remains visible regardless of which tag (1–9) you switch to on your physical screen.
5. **OBS / Discord / Zoom / Google Meet** captures `HEADLESS-1` via PipeWire, guaranteeing that personal workspaces on `eDP-1` are never seen by viewers.

---

## 2. Keybindings

| Shortcut | Action | Description |
| :--- | :--- | :--- |
| **`SUPER + v`** | `toggle-virtmon` | Toggle the virtual monitor and `wl-mirror` on or off. |
| **`SUPER + SHIFT + v`** | `tagmon, HEADLESS-1` | Move the currently active window onto the virtual monitor. |
| **`SUPER + CTRL + v`** | `focusmon, HEADLESS-1` | Jump keyboard & cursor focus to the virtual monitor. |

> **Tip:** You can return focus to your laptop screen using your standard directional focus shortcuts (e.g. `SUPER + h` / `SUPER + Left`) or by moving your mouse cursor back to the left.

---

## 3. Window Rules & Pinning Behavior

The module configures:
```nix
windowrule = [
  "isglobal:1,isfloating:1,width:640,height:360,appid:.*wl_mirror.*"
];
```

* **`isglobal:1` (Sticky / Pinned)**: Marks `wl-mirror` as a global window across all tags. When you switch tags on your physical display (`SUPER + 1..9`), the preview does not vanish or animate away.
* **`isfloating:1`**: Prevents the mirror from snapping into your active tiling or scroller layout, keeping it as an overlay.
* **`width:640,height:360`**: Initial 16:9 aspect ratio matching the 1080p virtual canvas without distortion or black bars.
* **Dynamic Fullscreen / Maximize**: You can still press **`SUPER + f`** to temporarily fullscreen the mirror for closer inspection, and press it again to restore it to the floating 640x360 size.

---

## 4. Operator Workflow Guide

### Starting a Presentation / Stream
1. Press **`SUPER + v`**.
   - A system notification confirms `HEADLESS-1` is active.
   - The pinned `wl-mirror` window appears on your screen.
2. Open the windows you want to share (e.g. Browser, Terminal, Editor).
3. Press **`SUPER + SHIFT + v`** on each window to toss it to the virtual monitor.
4. (Optional) Press **`SUPER + CTRL + v`** to jump keyboard focus into the virtual screen to manipulate windows, or move your mouse past the right edge of your physical display.

### Sharing in OBS or Meeting Apps
1. Open OBS (or Discord / Zoom / Meet).
2. Select **Screen Share** $\rightarrow$ **PipeWire Screen Capture**.
3. Choose **`HEADLESS-1`** from the screen picker.
4. Only windows on `HEADLESS-1` will be shared. All notifications and apps on `eDP-1` remain private.

### Tearing Down
1. Press **`SUPER + v`** again.
   - `wl-mirror` closes.
   - `HEADLESS-1` is destroyed.
   - Any windows remaining on `HEADLESS-1` automatically migrate back to your primary display (`eDP-1`).
