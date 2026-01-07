{
  #inputs,
  #config,
  #pkgs,
  pkgs-unstable,
  #lib,
  #nix4vscode,
  #system,
  #isDroid,
  username,
  ...
}:

{
  #Docker
  #if u are changing the config from root to rootless mode,
  #follow this: https://discourse.nixos.org/t/docker-rootless-containers-are-running-but-not-showing-in-docker-ps/47717
  #Enabling docker in rootless mode.
  #Don't forget to include the below commented commands to start the docker daemon service,
  #coz just enabling doesn't start the daemon

  
  #virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  #systemctl --user enable --now docker
  #systemctl --user start docker
  #systemctl --user status docker # to check the status

  #virt-manager - this requires the above declared libvirt
  programs.virt-manager = {
    enable = true;
    package = pkgs-unstable.virt-manager;
  };
  #libvirt https://wiki.nixos.org/wiki/Libvirt
  virtualisation.libvirtd = {
    enable = true;
    package = pkgs-unstable.libvirt;
    onShutdown = "shutdown";
  };
  virtualisation.spiceUSBRedirection.enable = true;
  users.groups.libvirtd.members = [ username ]; # or u have to add this :  users.users.<myuser>.extraGroups = [ "libvirtd" ];
  networking.firewall.trustedInterfaces = [ "virbr0" ];
  /*systemd.services.libvirt-default-network = {
    # Unit
    description = "Start libvirt default network";
    after = [ "libvirtd.service" ];
    # Service
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.libvirt}/bin/virsh net-start default";
      ExecStop = "${pkgs.libvirt}/bin/virsh net-destroy default";
      User = "root";
    };
    # Install
    wantedBy = [ "multi-user.target" ];
  };*/
  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        lockAll = true; # prevents overriding
        settings = {
          "org/virt-manager/virt-manager/connections" = {
            autoconnect = [ "qemu:///system" ];
            uris = [ "qemu:///system" ];
          };
        };
      }
    ];
  };

  /*
    #check out this issue: https://github.com/NixOS/nixpkgs/issues/223594
    #solutions for theissue are as below
    networking.firewall.trustedInterfaces = [ "virbr0" ]; #try this only if the below methods doesn't work
    #also sometimes u need to run one or more of the following commands for the network to work (see the wiki link above)
    # sudo virsh net-autostart default # auto setup on all launch
    # sudo virsh net-start default #manual each time
    #chck this: https://blog.programster.org/kvm-missing-default-network
  */

  # Podman
  # Enable common container config files in /etc/containers
  virtualisation.containers.enable = true;
  users.groups.podman.members = [ username ];
  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # Enables the Docker compatibility socket #also creates wrapper alias for docker commands
    dockerSocket.enable = true; # Creates a Docker-compatible socket

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
}