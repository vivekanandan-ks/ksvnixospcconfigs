{
  inputs,
  ...
}: {
  flake-file.inputs = {
    dank-calendar = {
      url = "github:AvengeMedia/dankcalendar";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.homeModules.nonDroid.dankcalendar = {lib, ...}: {
    imports = [
      inputs.dank-calendar.homeModules.default
    ];

    programs.dank-calendar = {
      enable = true;

      systemd = {
        enable = true;
        target = "mango-session.target";
      };

      settings = {
        timeFormat = "auto";
        use24HourClock = true;
        firstDayOfWeek = 1;

        # Reminders configuration
        remindersEnabled = true;
        defaultReminderMinutes = 30;
        snoozeMinutes = 5;
        reminderPersist = true;
        notificationSounds = true;
        allDayReminders = true;
        allDayReminderTime = "09:00";

        # Views & Behavior
        lastView = "month";
        syncIntervalMinutes = 30;
        showTrayIcon = true;
        closeBehavior = "minimize";
      };
    };

    # MangoWM keybinding to toggle DankCalendar window
    wayland.windowManager.mango.settings.bind = lib.mkAfter [
      "SUPER, c, spawn, dcal toggle"
    ];
  };
}
