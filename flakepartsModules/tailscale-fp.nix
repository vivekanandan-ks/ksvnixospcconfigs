{...}: {
  flake.nixosModules.tailscale = {username, ...}: {
    # 1. Enable Tailscale
    #services.tailscale.enable = true;
    services.tailscale.extraSetFlags = ["--operator=${username}"];

    # 2. Trust the Tailscale Interface
    # This ensures you can SSH into the machine via Tailscale without opening port 22 to the public internet
    networking.firewall.trustedInterfaces = ["tailscale0"];
  };

  flake.homeModules.nonDroid.tailscale-systray = {pkgs-unstable, ...}: {
    services.tailscale-systray = {
      #enable = true;
      package = pkgs-unstable.tailscale;
    };
  };
}
