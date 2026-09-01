_: {
  flake.nixosModules.battery-charge-control = {pkgs, ...}: let
    batteryLimitScript = pkgs.writeShellScriptBin "battery-limit" ''
      set -euo pipefail

      ARG="''${1:-70}"

      # Status check mode
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
            echo "IdeaPad Conservation Mode: $val ($([ "$val" -eq 1 ] && echo "Active - charging capped" || echo "Inactive - charging to 100%"))"
            found=1
          fi
        done
        if [ "$found" -eq 0 ]; then
          echo "No supported battery charging threshold interface found on this host."
        fi
        exit 0
      fi

      TARGET="$ARG"
      found=0

      # 1. Standard Linux kernel sysfs (ThinkPads, ASUS, Dell, Framework, etc.)
      for f in /sys/class/power_supply/BAT*/charge_control_end_threshold; do
        if [ -f "$f" ]; then
          echo "$TARGET" > "$f" && echo "Set $(basename "$(dirname "$f")") stop threshold to $TARGET%"
          chmod 0666 "$f" 2>/dev/null || true
          found=1

          # Set start threshold if supported (hysteresis of 5%)
          start_f="$(dirname "$f")/charge_control_start_threshold"
          if [ -f "$start_f" ]; then
            START_TARGET=$(( TARGET > 5 ? TARGET - 5 : 0 ))
            echo "$START_TARGET" > "$start_f" 2>/dev/null || true
            chmod 0666 "$start_f" 2>/dev/null || true
          fi
        fi
      done

      # 2. Lenovo IdeaPad conservation mode
      for f in /sys/bus/platform/drivers/ideapad_acpi/*/conservation_mode; do
        if [ -f "$f" ]; then
          MODE=$([ "$TARGET" -lt 100 ] && echo 1 || echo 0)
          echo "$MODE" > "$f" && echo "IdeaPad Conservation Mode set to $MODE (target: $TARGET%)"
          chmod 0666 "$f" 2>/dev/null || true
          found=1
          break
        fi
      done

      # 3. Desktop / VM / Unsupported
      if [ "$found" -eq 0 ]; then
        echo "No supported battery charging threshold interface found on this host."
      fi
    '';
  in {
    environment.systemPackages = [batteryLimitScript];

    # Apply 70% threshold on boot
    systemd.services.apply-battery-threshold = {
      description = "Apply battery charge threshold on boot";
      wantedBy = ["multi-user.target"];
      after = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${batteryLimitScript}/bin/battery-limit 70";
        RemainAfterExit = true;
      };
    };

    # Udev rules:
    # 1. Ensure permissions are set for non-root users/scripts
    # 2. Re-apply threshold when AC adapter is plugged in
    services.udev.extraRules = ''
      ACTION=="add|change", SUBSYSTEM=="power_supply", ATTR{charge_control_end_threshold}!="", RUN+="${pkgs.coreutils}/bin/chmod 0666 /sys%p/charge_control_end_threshold"
      ACTION=="add|change", SUBSYSTEM=="platform", DRIVERS=="ideapad_acpi", RUN+="${pkgs.coreutils}/bin/chmod 0666 /sys%p/conservation_mode"
      ACTION=="change", SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="${batteryLimitScript}/bin/battery-limit 70"
    '';
  };
}
