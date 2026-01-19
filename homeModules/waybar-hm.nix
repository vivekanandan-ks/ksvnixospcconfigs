{
  #inputs,
  #config,
  #lib,
  #pkgs,
  pkgs-unstable,
  ...
}: {
  programs.waybar = {
    #enable = true;
    package = pkgs-unstable.waybar;
    systemd.enable = true;

    settings = {
      topBar = {
        layer = "top";
        position = "bottom";
        height = 36;
        spacing = 4;
        
        modules-left = [
          "hyprland/window" # 1. Window Title
        ];
        
        modules-center = [
          "hyprland/workspaces" # 4. Pager
          "wlr/taskbar" # 5. Icons-Only Task Manager
          "mpris" # 6. Media Controls (Middle)
        ];
        
        modules-right = [
          "network" # 8. Netspeed Widget
          "disk" # 9. Disk Usage
          "cpu" # 12. Core Usage
          "memory" # 13. Memory Usage
          "privacy" # 15. Camera Indicator
          "tray" # 16. System Tray
          "pulseaudio" # Speakers
          "pulseaudio#microphone" # Microphone
          "bluetooth" # Bluetooth
          "backlight" # Brightness
          "idle_inhibitor" # Screensaver Toggle (Requested on Battery)
          "battery" # Battery Status
          "clock" # 17. Digital Clock
        ];

        # 1. Window Title
        "hyprland/window" = {
          max-length = 50;
          separate-outputs = true;
        };

        # 4. Pager
        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          format = "{name}";
        };
        
        # 5. Icons-Only Task Manager
        "wlr/taskbar" = {
          format = "{icon}";
          icon-size = 18;
          tooltip-format = "{title}";
          on-click = "activate";
          on-click-middle = "close";
          ignore-list = [
            "wofi"
          ];
          app_ids-mapping = {
            "firefoxdeveloperedition" = "firefox-developer-edition";
          };
          rewrite = {
            "Firefox Web Browser" = "Firefox";
          };
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

        # Brightness
        "backlight" = {
          device = "intel_backlight";
          format = "{percent}% {icon}";
          format-icons = ["" ""];
          on-scroll-up = "brightnessctl set +5%";
          on-scroll-down = "brightnessctl set 5%-";
        };

        # 8. Netspeed Widget
        "network" = {
          format-wifi = "{essid} ({signalStrength}%)   ⬇{bandwidthDownBytes} ⬆{bandwidthUpBytes}";
          format-ethernet = " ⬇{bandwidthDownBytes} ⬆{bandwidthUpBytes}";
          format-linked = "{ifname} (No IP) ";
          format-disconnected = "Disconnected ⚠";
          interval = 1;
        };

        # 9. Disk Usage
        "disk" = {
          interval = 30;
          format = " {percentage_used}%";
          path = "/";
        };

        # 12. Core Usage
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

        # Speakers
        "pulseaudio" = {
          format = "{volume}% {icon}";
          format-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = ["" "" ""];
          };
          scroll-step = 5;
          on-click = "pwvucontrol";
          on-click-middle = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
        };

        # Microphone
        "pulseaudio#microphone" = {
          format = "{format_source}";
          format-source = "{volume}% ";
          format-source-muted = "";
          scroll-step = 5;
          on-click = "pwvucontrol";
          on-click-middle = "pactl set-source-mute @DEFAULT_SOURCE@ toggle";
        };

        # Bluetooth
        "bluetooth" = {
          format = " {status}";
          format-connected = " {device_alias}";
          format-connected-battery = " {device_alias} {device_battery_percentage}%";
          tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          on-click = "kitty -e bluetuith";
          on-click-middle = "rfkill toggle bluetooth";
        };

        # Idle Inhibitor (Simulating Battery Middle Click)
        "idle_inhibitor" = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
          tooltip = true;
          tooltip-format-activated = "Power Saving: OFF (Presentation Mode)";
          tooltip-format-deactivated = "Power Saving: ON";
        };

        # Battery
        "battery" = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% ";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          format-icons = ["" "" "" "" ""];
        };

        # 17. Digital Clock
        "clock" = {
          format = "{%H:%M:%S}";
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
        font-weight: bold; /* Bold fonts as requested */
        min-height: 0;
      }

      window#waybar {
        /* background: rgba(30, 30, 46, 0.6); Translucent base */
        /* color: #cdd6f4; */
      }

      #workspaces button {
        padding: 0 5px;
        background-color: transparent;
        /* color: #cdd6f4; */
      }

      #workspaces button:hover {
        background: rgba(255, 255, 255, 0.1);
      }

      #workspaces button.active {
        /* background-color: #cba6f7; Accent placeholder */
        /* color: #1e1e2e; */
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #disk,
      #network,
      #pulseaudio,
      #mpris,
      #backlight,
      #bluetooth,
      #idle_inhibitor,
      #tray {
        padding: 0 10px;
        margin: 4px;
        border-radius: 10px;
        /* color: #1e1e2e; Text color for modules with background */
      }

      #clock {
        /* background-color: #a6e3a1; Green */
        font-size: 16px;
        font-weight: bold;
      }

      #window {
        margin: 0 4px;
        /* color: #cdd6f4; */
      }

      /* Module Colors - Inspired by Catppuccin/KDE Theme */
      
      #pulseaudio {
        /* background-color: #f38ba8; Red/Pink */
      }
      
      #pulseaudio.microphone {
        /* background-color: #f38ba8; Red/Pink */
      }

      #backlight {
        /* background-color: #fab387; Orange */
      }
      
      #bluetooth {
        /* background-color: #89b4fa; Blue */
      }

      #cpu {
        /* background-color: #fab387; Orange */
      }

      #memory {
        /* background-color: #f9e2af; Yellow */
      }

      #disk {
        /* background-color: #94e2d5; Teal */
      }

      #network {
        /* background-color: #89b4fa; Blue */
      }

      #mpris {
        /* background-color: #cba6f7; Mauve */
      }

      #tray {
        /* background-color: #45475a; */
        /* color: #cdd6f4; */
      }
    '';
  };
}