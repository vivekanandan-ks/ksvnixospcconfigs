_: {
  flake.nixosModules.docker = { ... }: {
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
  };
}
