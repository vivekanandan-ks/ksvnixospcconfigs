{
  #inputs,
  #config,
  pkgs,
  #pkgs-unstable,
  #lib,
  #nix4vscode,
  #system,
  username,
  ...
}: {
  # 1. Enable Tailscale
  services.tailscale.enable = true;
  services.tailscale.extraSetFlags = ["--operator=${username}"];

  # 2. Trust the Tailscale Interface
  # This ensures you can SSH into the machine via Tailscale without opening port 22 to the public internet
  networking.firewall.trustedInterfaces = ["tailscale0"];

  # 3. Enable SSH Server
  services.openssh = {
    enable = true;
    settings = {
      # Optional: Disable password auth for security (if you set up keys)
      # PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
}
