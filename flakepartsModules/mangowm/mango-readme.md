# MangoWM Keybindings & Module Reference

Declarative [Mango](https://github.com/mangowm/mango) Wayland compositor configuration managed via NixOS and Home Manager flake-parts modules.

---

## 1. Module Structure

* [`mangowm-fp.nix`](file:///home/ksvnixospc/Documents/ksvnixospcconfigs/flakepartsModules/mangowm/mangowm-fp.nix): System session wrapper, NixOS module, Home Manager module, and `cliphist` clipboard daemon integration.
* [`mangowm-settings-fp.nix`](file:///home/ksvnixospc/Documents/ksvnixospcconfigs/flakepartsModules/mangowm/mangowm-settings-fp.nix): Visual styling (full-scene blur, shadows, borderless windows, zoom/fade animations), layout definitions (scroller default), and hot corner configuration.
* [`mangowm-bindings-fp.nix`](file:///home/ksvnixospc/Documents/ksvnixospcconfigs/flakepartsModules/mangowm/mangowm-bindings-fp.nix): Keyboard shortcuts for navigation, layouts, scratchpad, window states, and shell actions.

---

## 2. Keybindings Reference

### Window Sizing & States ("F" Family)
| Shortcut | Action | Description |
| :--- | :--- | :--- |
| `SUPER + f` | `togglefullscreen` | Fullscreen edge-to-edge (covers panels/bars, no borders). |
| `SUPER + ALT + f` | `togglemaximizescreen` | Maximize window across work area (keeps panels and bars visible). |
| `SUPER + SHIFT + f` | `togglefloating` | Toggle between tiled layout and free floating window. |
| `SUPER + g` | `toggleglobal` | Pin window across all tags/workspaces. |

### Scratchpad / Minimize ("M" Family)
| Shortcut | Action | Description |
| :--- | :--- | :--- |
| `SUPER + m` | `minimized` | Stash focused window into the scratchpad (hides and unsets tags). |
| `SUPER + ALT + m` | `toggle_scratchpad` | Summon, cycle, or hide scratchpad window as a centered floating overlay. |
| `SUPER + SHIFT + m` | `restore_minimized, 0` | Restore scratchpad window back to normal tiled layout on current tag. |

### Shell & System Controls
| Shortcut | Action | Description |
| :--- | :--- | :--- |
| `SUPER + Space` | DMS Spotlight toggle | Open quick application launcher. |
| `SUPER + w` | DMS Wallpaper Carousel | Toggle wallpaper selector. |
| `CTRL + ALT + Delete` | DMS Powermenu | Open power & session menu. |
| `ALT + F4` | `killclient` | Close active window. |
| `SUPER + Tab` | `overcircle, next` | Mission control / window overview. |
| `SUPER + SHIFT + Tab` | `togglejump` | Toggle overview jump mode. |
| `ALT + Tab` | `switcher, next` | Window thumbnail HUD switcher. |
| `ALT + SHIFT + Tab` | `switcher, all_tag_next` | Switcher HUD across all tags. |
| `ALT + \`` | `focuslast` | Focus last active window. |

### Window Focus
| Shortcut | Action | Description |
| :--- | :--- | :--- |
| `SUPER + h` / `Left` | `focusdir, left` | Directional focus left. |
| `SUPER + l` / `Right` | `focusdir, right` | Directional focus right. |
| `SUPER + k` / `Up` | `focusdir, up` | Directional focus up. |
| `SUPER + j` / `Down` | `focusdir, down` | Directional focus down. |
| `SUPER + ,` | `focusstack, prev` | Focus previous window in stack. |
| `SUPER + .` | `focusstack, next` | Focus next window in stack. |

### Layout Switching
| Shortcut | Layout | Shortcut | Layout |
| :--- | :--- | :--- | :--- |
| `ALT + SHIFT + 1` | `scroller` | `ALT + SHIFT + 8` | `right_tile` |
| `ALT + SHIFT + 2` | `tile` | `ALT + SHIFT + 9` | `vertical_scroller` |
| `ALT + SHIFT + 3` | `dwindle` | `ALT + SHIFT + 0` | `vertical_tile` |
| `ALT + SHIFT + 4` | `grid` | `ALT + SHIFT + -` | `vertical_grid` |
| `ALT + SHIFT + 5` | `monocle` | `ALT + SHIFT + =` | `vertical_deck` |
| `ALT + SHIFT + 6` | `deck` | `ALT + SHIFT + [` | `fair` |
| `ALT + SHIFT + 7` | `center_tile` | `ALT + SHIFT + ]` | `vertical_fair` |
| `SUPER + \` | `switch_layout` | *Cycle through layouts* | |

### Workspace / Tag Navigation
| Shortcut Pattern | Action | Description |
| :--- | :--- | :--- |
| `SUPER + [1-9]` | `view, <tag>` | Switch view to workspace/tag. |
| `SUPER + SHIFT + [1-9]` | `tag, <tag>` | Move window and FOLLOW to workspace/tag. |
| `SUPER + ALT + [1-9]` | `tagsilent, <tag>` | Move window SILENTLY to workspace/tag. |
| `SUPER + CTRL + [1-9]` | `toggletag, <tag>` | Toggle window presence on workspace/tag. |
| `SUPER + [` | `viewtoleft` | Switch to workspace on left. |
| `SUPER + ]` | `viewtoright` | Switch to workspace on right. |
| `SUPER + SHIFT + [` | `tagtoleft` | Move window to workspace on left. |
| `SUPER + SHIFT + ]` | `tagtoright` | Move window to workspace on right. |

### Mouse Bindings
| Shortcut | Action | Description |
| :--- | :--- | :--- |
| `SUPER + Left Click` | `moveresize, curmove` | Drag to move window. |
| `SUPER + Right Click` | `moveresize, curresize` | Drag to resize window. |
