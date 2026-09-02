{lib, ...}: {
  flake.nixosModules.battery-charge-control = {pkgs, ...}: let
    batteryLimit = pkgs.writeShellScriptBin "battery-limit" ''
      set -euo pipefail

      ARG="''${1:-toggle}"

      # -------------------------------------------------------------
      # 1. Short status for DMS widget bar / DankActions (--short / -q)
      # -------------------------------------------------------------
      if [ "$ARG" = "--short" ] || [ "$ARG" = "-q" ]; then
        for f in /sys/bus/platform/drivers/ideapad_acpi/*/conservation_mode; do
          if [ -f "$f" ]; then
            [ "$(cat "$f")" -eq 1 ] && echo "60% 🛡️" || echo "100% ⚡"
            exit 0
          fi
        done
        for f in /sys/class/power_supply/BAT*/charge_control_end_threshold; do
          if [ -f "$f" ]; then
            val=$(cat "$f")
            [ "$val" -lt 100 ] && echo "''${val}% 🛡️" || echo "100% ⚡"
            exit 0
          fi
        done
        echo "N/A"
        exit 0
      fi

      # -------------------------------------------------------------
      # 2. Detailed status check (status / -s)
      # -------------------------------------------------------------
      if [ "$ARG" = "status" ] || [ "$ARG" = "-s" ]; then
        found=0
        for f in /sys/class/power_supply/BAT*/charge_control_end_threshold; do
          if [ -f "$f" ]; then
            echo "$(basename "$(dirname "$f")") stop threshold: $(cat "$f")%"
            start_f="$(dirname "$f")/charge_control_start_threshold"
            [ -f "$start_f" ] && echo "$(basename "$(dirname "$f")") start threshold: $(cat "$start_f")%"
            found=1
          fi
        done
        for f in /sys/bus/platform/drivers/ideapad_acpi/*/conservation_mode; do
          if [ -f "$f" ]; then
            val=$(cat "$f")
            echo "IdeaPad Conservation Mode: $val ($([ "$val" -eq 1 ] && echo "Active - 60% limit" || echo "Inactive - 100%"))"
            found=1
          fi
        done
        if [ "$found" -eq 0 ]; then
          echo "No supported battery charging threshold interface found on this host."
        fi
        exit 0
      fi

      # -------------------------------------------------------------
      # 3. Determine target threshold
      # -------------------------------------------------------------
      TARGET=""
      if [ "$ARG" = "toggle" ]; then
        # Check IdeaPad
        for f in /sys/bus/platform/drivers/ideapad_acpi/*/conservation_mode; do
          if [ -f "$f" ]; then
            TARGET=$([ "$(cat "$f")" -eq 1 ] && echo 100 || echo 60)
            break
          fi
        done
        # Check Standard Linux sysfs if not IdeaPad
        if [ -z "$TARGET" ]; then
          for f in /sys/class/power_supply/BAT*/charge_control_end_threshold; do
            if [ -f "$f" ]; then
              TARGET=$([ "$(cat "$f")" -lt 100 ] && echo 100 || echo 80)
              break
            fi
          done
        fi
      elif [ "$ARG" = "on" ]; then
        TARGET=80
      elif [ "$ARG" = "off" ]; then
        TARGET=100
      else
        TARGET="$ARG"
      fi

      if [ -z "$TARGET" ]; then
        echo "Error: Could not determine battery target threshold." >&2
        exit 1
      fi

      found=0

      write_sysfs() {
        local val="$1"
        local file="$2"
        if [ -w "$file" ]; then
          echo "$val" > "$file"
          return 0
        fi
        if command -v pkexec >/dev/null 2>&1; then
          if pkexec sh -c "echo '$val' > '$file'"; then
            return 0
          fi
        fi
        return 1
      }

      # -------------------------------------------------------------
      # 4. Apply to Standard sysfs (ThinkPads, ASUS, Dell, Framework, etc.)
      # -------------------------------------------------------------
      for f in /sys/class/power_supply/BAT*/charge_control_end_threshold; do
        if [ -f "$f" ]; then
          if write_sysfs "$TARGET" "$f"; then
            echo "Set $(basename "$(dirname "$f")") stop threshold to $TARGET%"
            found=1

            start_f="$(dirname "$f")/charge_control_start_threshold"
            if [ -f "$start_f" ]; then
              START_TARGET=$(( TARGET > 5 ? TARGET - 5 : 0 ))
              write_sysfs "$START_TARGET" "$start_f" || true
            fi
          else
            echo "Failed to write to $f" >&2
            ${pkgs.libnotify}/bin/notify-send -u critical -i dialog-error "Battery Protection" "Permission Denied: Run 'sudo chmod 666 $f' or authenticate." || true
            exit 1
          fi
        fi
      done

      # -------------------------------------------------------------
      # 5. Apply to Lenovo IdeaPad Conservation Mode
      # -------------------------------------------------------------
      for f in /sys/bus/platform/drivers/ideapad_acpi/*/conservation_mode; do
        if [ -f "$f" ]; then
          MODE=$([ "$TARGET" -lt 100 ] && echo 1 || echo 0)
          if write_sysfs "$MODE" "$f"; then
            echo "IdeaPad Conservation Mode set to $MODE ($([ "$MODE" -eq 1 ] && echo "60% cap" || echo "100%"))"
            TARGET=$([ "$MODE" -eq 1 ] && echo 60 || echo 100)
            found=1
          else
            echo "Failed to write to $f" >&2
            ${pkgs.libnotify}/bin/notify-send -u critical -i dialog-error "Battery Protection" "Permission Denied: Run 'sudo chmod 666 $f' or authenticate." || true
            exit 1
          fi
          break
        fi
      done

      # -------------------------------------------------------------
      # 6. Notification & Desktop Feedback
      # -------------------------------------------------------------
      if [ "$found" -eq 1 ]; then
        if [ "$TARGET" -lt 100 ]; then
          ${pkgs.libnotify}/bin/notify-send -u normal -i battery-charging "Battery Protection" "Limit Active: Capped at ''${TARGET}%" || true
        else
          ${pkgs.libnotify}/bin/notify-send -u normal -i battery-full "Battery Protection" "Full Charge Enabled: Charging to 100%" || true
        fi
      else
        echo "No supported battery charging threshold interface found on this host."
        ${pkgs.libnotify}/bin/notify-send -u low -i battery-missing "Battery Protection" "No battery hardware found on this host." || true
      fi
    '';
  in {
    environment.systemPackages = [
      batteryLimit
      pkgs.libnotify
    ];

    # Ensure sysfs files are world-writable across reboots via systemd tmpfiles
    systemd.tmpfiles.rules = [
      "z /sys/bus/platform/drivers/ideapad_acpi/*/conservation_mode 0666 root root -"
      "z /sys/class/power_supply/BAT*/charge_control_end_threshold 0666 root root -"
      "z /sys/class/power_supply/BAT*/charge_control_start_threshold 0666 root root -"
    ];

    # Udev rules granting write access dynamically on device add/change events
    services.udev.extraRules = ''
      ACTION=="add|change", SUBSYSTEM=="platform", ATTR{conservation_mode}!="", RUN+="${pkgs.coreutils}/bin/chmod 0666 /sys%p/conservation_mode"
      ACTION=="add|change", SUBSYSTEM=="platform", KERNEL=="VPC2004:00", RUN+="${pkgs.coreutils}/bin/chmod 0666 /sys%p/conservation_mode"
      ACTION=="add|change", SUBSYSTEM=="power_supply", ATTR{charge_control_end_threshold}!="", RUN+="${pkgs.coreutils}/bin/chmod 0666 /sys%p/charge_control_end_threshold"
      ACTION=="add|change", SUBSYSTEM=="power_supply", ATTR{charge_control_start_threshold}!="", RUN+="${pkgs.coreutils}/bin/chmod 0666 /sys%p/charge_control_start_threshold"
    '';
  };

  # Home-manager module for nonDroid hosts: MangoWM keybinding integration
  flake.homeModules.nonDroid.battery-charge-control = _: {
    wayland.windowManager.mango.settings.bind = lib.mkAfter [
      "SUPER+ALT, b, spawn, battery-limit toggle"
    ];
  };
}
