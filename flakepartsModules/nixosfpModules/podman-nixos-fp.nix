_: {
  flake.nixosModules.podman = {
    username,
    ...
  }: {
    # Podman
    # Enable common container config files in /etc/containers
    virtualisation.containers.enable = true;
    users.groups.podman.members = [username];
    virtualisation.podman = {
      enable = true;
      # dockerCompat = true; # Enables the Docker compatibility socket #also creates wrapper alias for docker commands
      dockerSocket.enable = true; # Creates a Docker-compatible socket

      # Default network settings
      defaultNetwork.settings = {
        dns_enabled = true; # Enable DNS server for containers
        #network_interface = "podman0";  # Default network interface name
      };
      /*
      #Auto-pruning
      autoPrune = {
        enable = true;
        dates = "weekly";  # When to run: "daily", "weekly", etc.
        flags = [ "--all" "--volumes" ];  # Additional flags
      };

      #Container settings
      settings = {
        engine = {
          cgroup_manager = "systemd";  # Use systemd for cgroup management
          events_logger = "journald";  # Log to journald
          runtime = "crun";  # Default runtime
          volume_path = "$HOME/.local/share/containers/storage/volumes";  # Custom volume path
        };
      */

      # Default network settings
      defaultNetwork.settings = {
        dns_enabled = true; # Enable DNS server for containers
        #network_interface = "podman0";  # Default network interface name
      };
    };
  };
}
