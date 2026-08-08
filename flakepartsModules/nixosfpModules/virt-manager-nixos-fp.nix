_: {
  flake.nixosModules.virt-manager = {
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
  }: {
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
    users.groups.libvirtd.members = [username]; # or u have to add this :  users.users.<myuser>.extraGroups = [ "libvirtd" ];
    networking.firewall.trustedInterfaces = ["virbr0"];
    /*
      systemd.services.libvirt-default-network = {
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
    };
    */
    programs.dconf = {
      enable = true;
      profiles.user.databases = [
        {
          lockAll = true; # prevents overriding
          settings = {
            "org/virt-manager/virt-manager/connections" = {
              autoconnect = ["qemu:///system"];
              uris = ["qemu:///system"];
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
  };
}
