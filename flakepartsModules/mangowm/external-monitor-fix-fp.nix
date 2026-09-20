_: {
  flake.hostModules.akashnixospc.external-monitor-fix = {
    username,
    ...
  }: {
    home-manager.users.${username} = {
      wayland.windowManager.mango.settings.monitorrule = [
        "name:HDMI-A-1,width:1920,height:1080,refresh:60,scale:1"
      ];
    };
  };
}
