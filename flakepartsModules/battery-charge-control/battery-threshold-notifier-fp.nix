{lib, ...}: {
  flake.nixosModules.battery-threshold-notifier = {pkgs, ...}: let
    batteryNotifierCheck = pkgs.writeShellScriptBin "battery-notifier-check" ''
      set -euo pipefail

      # 1. Exit immediately if no battery hardware exists on this host (e.g. Desktops)
      has_bat=0
      for b in /sys/class/power_supply/BAT*; do
        if [ -d "$b" ]; then
          has_bat=1
          break
        fi
      done
      if [ "$has_bat" -eq 0 ]; then
        exit 0
      fi

      # 2. Setup state directory in user tmpfs runtime directory
      STATE_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/battery-notifier"
      mkdir -p "$STATE_DIR"

      # Helper to check if AC power adapter is connected
      is_ac_online() {
        for ac in /sys/class/power_supply/AC* /sys/class/power_supply/ADP*; do
          if [ -f "$ac/online" ]; then
            read -r ac_val < "$ac/online" 2>/dev/null || ac_val="0"
            if [ "$ac_val" = "1" ]; then
              return 0
            fi
          fi
        done
        return 1
      }

      ac_connected=0
      is_ac_online && ac_connected=1

      # 3. Inspect all batteries (handles multi-battery devices cleanly)
      for bat in /sys/class/power_supply/BAT*; do
        [ -d "$bat" ] || continue
        bat_name="$(basename "$bat")"
        state_file="$STATE_DIR/$bat_name.state"

        # Load persisted flags (0 = not sent, 1 = sent)
        notified_high=0
        notified_low=0
        if [ -f "$state_file" ]; then
          # shellcheck disable=SC1090
          . "$state_file" 2>/dev/null || true
        fi

        capacity=""
        status=""
        [ -f "$bat/capacity" ] && read -r capacity < "$bat/capacity" || true
        [ -f "$bat/status" ] && read -r status < "$bat/status" || true

        if [ -n "$capacity" ] && [ -n "$status" ]; then
          # =========================================================
          # CASE 1: AC Connected / Charging (80%+ Alert with Hysteresis)
          # =========================================================
          if [ "$ac_connected" -eq 1 ] || [ "$status" = "Charging" ] || [ "$status" = "Full" ]; then
            # Re-arm low alert since we are plugged in
            notified_low=0

            if [ "$capacity" -ge 80 ]; then
              if [ "$notified_high" -eq 0 ]; then
                ${pkgs.libnotify}/bin/notify-send -u normal -i battery-charging \
                  "Battery Charged: 80% Safeguard" \
                  "Battery level has reached ''${capacity}%. Consider unplugging the charger to preserve long-term battery health." || true
                notified_high=1
              fi
            elif [ "$capacity" -le 75 ]; then
              # Hysteresis reset: only re-arm high alert once dropped to 75%
              notified_high=0
            fi

          # =========================================================
          # CASE 2: On Battery / Discharging (50%- Alert with Hysteresis)
          # =========================================================
          elif [ "$status" = "Discharging" ]; then
            # Re-arm high alert since we are discharging
            notified_high=0

            if [ "$capacity" -le 50 ]; then
              if [ "$notified_low" -eq 0 ]; then
                ${pkgs.libnotify}/bin/notify-send -u normal -i battery-low \
                  "Battery Advisory: 50% Remaining" \
                  "Battery level is now at ''${capacity}%. Half of your charge has been consumed." || true
                notified_low=1
              fi
            elif [ "$capacity" -ge 55 ]; then
              # Hysteresis reset: only re-arm low alert once charged above 55%
              notified_low=0
            fi
          fi
        fi

        # Save state atomically to tmpfs
        cat <<EOF > "$state_file"
notified_high=$notified_high
notified_low=$notified_low
EOF
      done
    '';
  in {
    environment.systemPackages = [
      batteryNotifierCheck
      pkgs.libnotify
    ];

    # Oneshot service executed on each timer pulse (<2ms execution)
    systemd.user.services.battery-threshold-notifier = {
      description = "Automated Battery Threshold Notifier (80% Charge & 50% Discharge Alerts)";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${batteryNotifierCheck}/bin/battery-notifier-check";
      };
    };

    # Systemd Timer: pulses every 3 minutes with 30s power-saving alignment
    systemd.user.timers.battery-threshold-notifier = {
      description = "Timer for Battery Threshold Notifier";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "1m";
        OnUnitActiveSec = "3m";
        AccuracySec = "30s";
        Persistent = false;
      };
    };
  };
}
