{
  #inputs,
  #config,
  #lib,
  #pkgs,
  pkgs-unstable,
  #username,
  ...
}: {
  home.packages = with pkgs-unstable; [
    brightnessctl
  ];
  # for this xremap to work as user , have to add these to the configuration.nix
  #hardware.uinput.enable = true;
  #users.groups.uinput.members = [username];
  #users.groups.input.members = [username];

  # key names link:
  # https://github.com/xremap/xremap
  # https://github.com/emberian/evdev/blob/main/src/scancodes.rs
  services.xremap = {
    enable = true;
    withKDE = true;
    #serviceMode = "user";
    #userName = username;
    config = {
      keymap = [
        {
          name = "Basic shortcuts";
          remap = {
            CTRL-ALT-z.remap = {
              t.launch = ["konsole"];
              k.launch = ["kitty"];
              g.launch = ["ghostty"];
              #w.launch = ["warp-terminal"];
              w.remap.p.launch = ["warp-terminal"];
              w.remap.e.launch = ["waveterm"];
            };
            Ctrl-Alt-a.remap = {
              t.launch = ["Telegram"];
              f.launch = ["firefox"];
              c.launch = ["google-chrome-stable"];
              v.launch = ["code"]; # vscode
              z.remap.d.launch = ["zeditor"];
              z.remap.n.launch = ["zen"];
            };
            # super-f1.launch = ["wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"];
            # super-f2.launch = ["wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"];
            # super-f3.launch = ["brightnessctl set +5%"];
            # super-f4.launch = ["brightnessctl set 5%-"];
            Super-F1.launch = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"];
            Super-F2.launch = ["wpctl" "set-volume" /*"-l" "1.5"*/ "@DEFAULT_AUDIO_SINK@" "5%+"];
            # Option 1: brightnessctl (No OSD)
            #Super-F3.launch = ["brightnessctl" "set" "5%-"];
            #Super-F4.launch = ["brightnessctl" "set" "+5%"];

            # Option 2: Direct Key Remap (Triggers Super key menu issue)
            # Super-F3 = "KEY_BRIGHTNESSDOWN";
            # Super-F4 = "KEY_BRIGHTNESSUP";

            # Option 3: Invoke KDE Shortcut (Recommended - Triggers internal PowerDevil action)
            Super-F3.launch = ["qdbus" "org.kde.kglobalaccel" "/component/org_kde_powerdevil" "org.kde.kglobalaccel.Component.invokeShortcut" "Decrease Screen Brightness"];
            Super-F4.launch = ["qdbus" "org.kde.kglobalaccel" "/component/org_kde_powerdevil" "org.kde.kglobalaccel.Component.invokeShortcut" "Increase Screen Brightness"];
          };
        }
      ];
    };
  };
}
