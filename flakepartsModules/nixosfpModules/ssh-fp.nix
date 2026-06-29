{ ... }: {
  flake.nixosModules.ssh = {
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


  # 3. Enable SSH Server
  services.openssh = {
    enable = true;
    settings = {
      # Optional: Disable password auth for security (if you set up keys)
      # PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
    };
  };
}
