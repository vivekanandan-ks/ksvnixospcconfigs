{
  #inputs,
  #config,
  #lib,
  #pkgs,
  pkgs-unstable,
  ...
}: {
  programs.waybar = {
    enable = true;
    package = pkgs-unstable.waybar;
    systemd.enable = true;

    settings = {
      topBar = {
        layer = "top";
        position = "bottom";
        height = 30;
        spacing = 4;
        
        modules-left = [
          "hyprland/window" # 1. Window Title
        ];
        
        modules-center = [
          "hyprland/workspaces" # 4. Pager
          "wlr/taskbar" # 5. Icons-Only Task Manager (Equivalent)
        ];
        
        modules-right = [
          "mpris" # 6. PlasMusic Toolbar
          "network" # 8. Netspeed Widget
          "disk" # 9. Disk Usage & 10. Hard Disk Activity
          "cpu" # 12. Individual Core Usage
          "memory" # 13. Memory Usage
          "privacy" # 15. Camera Indicator
          "tray" # 16. System Tray
          "pulseaudio" # Audio (Requested functionality + pwvucontrol)
          "clock" # 17. Digital Clock
        ];

        # 1. Window Title
        "hyprland/window" = {
          max-length = 50;
        };

        # 4. Pager
        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          format = "{name}";
        };
        
        # 5. Icons-Only Task Manager
        "wlr/taskbar" = {
          on-click = "activate";
          on-click-middle = "close";
          tooltip-format = "{title}";
        };

        # 6. PlasMusic Toolbar
        "mpris" = {
          format = "{player_icon} {title}";
          format-paused = "{status_icon} {title}";
          player-icons = {
            default = "▶";
            mpv = "🎵";
          };
          status-icons = {
            paused = "⏸";
          };
          max-length = 30;
        };

        # 8. Netspeed Widget
        "network" = {
          format-wifi = "{essid} ({signalStrength}%)   ⬇{bandwidthDownBytes} ⬆{bandwidthUpBytes}";
          format-ethernet = " ⬇{bandwidthDownBytes} ⬆{bandwidthUpBytes}";
          format-linked = "{ifname} (No IP) ";
          format-disconnected = "Disconnected ⚠";
          interval = 1;
        };

        # 9. Disk Usage & 10. Hard Disk Activity
        "disk" = {
          interval = 30;
          format = " {percentage_used}%";
          path = "/";
        };

        # 12. Individual Core Usage
        "cpu" = {
          interval = 1;
          format = " {usage}%";
          tooltip = true;
        };

        # 13. Memory Usage
        "memory" = {
          interval = 3;
          format = " {percentage}%";
        };

        # 15. Camera Indicator
        "privacy" = {
          icon-spacing = 4;
          icon-size = 18;
          transition-duration = 250;
          modules = [
            {
              type = "screenshare";
              tooltip = true;
              tooltip-icon-size = 24;
            }
            {
              type = "audio-in";
              tooltip = true;
              tooltip-icon-size = 24;
            }
            {
              type = "audio-out";
              tooltip = true;
              tooltip-icon-size = 24;
            }
          ];
        };

        # 16. System Tray
        "tray" = {
          spacing = 10;
        };

        # Audio + pwvucontrol request
        "pulseaudio" = {
          format = "{volume}% {icon} {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
          format-source = "{volume}% ";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = ["" "" ""];
          };
          on-click = "pwvucontrol";
        };

        # 17. Digital Clock
        "clock" = {
          format = "{:%H:%M:%S}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          interval = 1;
        };
      };
    };

    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: Roboto, Helvetica, Arial, sans-serif;
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background: rgba(30, 30, 46, 0.6); /* Translucent (KDE inactiveBackground #1e1e2e) */
        color: #cdd6f4; /* KDE inactiveForeground */
      }

      #workspaces button {
        padding: 0 5px;
        background-color: transparent;
        color: #cdd6f4;
      }

      #workspaces button:hover {
        background: rgba(255, 255, 255, 0.1);
      }

      #workspaces button.active {
        background-color: #cba6f7; /* Accent Color-ish */
        color: #1e1e2e;
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #disk,
      #network,
      #pulseaudio,
      #mpris,
      #tray {
        padding: 0 10px;
        margin: 4px;
        border-radius: 10px;
        color: #1e1e2e; /* Text color for modules with background */
      }

      #window {
        margin: 0 4px;
        color: #cdd6f4;
      }

      /* Module Colors - Inspired by Catppuccin/KDE Theme */
      
      #pulseaudio {
        background-color: #f38ba8; /* Red/Pink */
      }

      #clock {
        background-color: #a6e3a1; /* Green */
      }

      #cpu {
        background-color: #fab387; /* Orange */
      }

      #memory {
        background-color: #f9e2af; /* Yellow */
      }

      #disk {
        background-color: #94e2d5; /* Teal */
      }

      #network {
        background-color: #89b4fa; /* Blue */
      }

      #mpris {
        background-color: #cba6f7; /* Mauve */
      }

      #tray {
        background-color: #45475a;
        color: #cdd6f4;
      }
    '';
  };
}
