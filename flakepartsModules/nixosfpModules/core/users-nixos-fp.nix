{self, ...}: {
  flake.nixosModules.users = {
    config,
    lib,
    pkgs-unstable,
    username,
    ...
  }: let
    userShell = self.personas.ksv.personalShell pkgs-unstable;
  in {
    users.mutableUsers = false; # this will make all user management only via nixos and
    #imperative user creations or anything in kde or commands won't persist the nixos-rebuild command.

    #root password
    users.users.root.hashedPassword = "$6$/Yo/IR.A6rGbFVr6$a6c7yhjPYGuJOBBkcPXl/SjZ531tEUHtkY3tX3np2dcX6JpZg.Myrwdnz.fhqci0Sg83vU8lDYmdpSAQqD.OF0";
    # Define a user account
    users.users."${username}" = {
      isNormalUser = true;
      description = self.personas.ksv.personalName;
      extraGroups = [
        "networkmanager"
        "wheel"
        "systemd-journal"
        "media"
      ];
      hashedPassword = "$6$DmrUUL7YWFMar6aA$sAoRlSbFH/GYETfXGTGa6GSTEsBEP1lQ6oRdXlQUsqhRB7OTI2vTmVlx64B2ihcez8B0q0l8/Vx1pO8c82bxm0";
      shell = userShell;
      #shell = pkgs-unstable.fish;
      /*
       packages =
      (with pkgs-stable; [
        #stable
      ])
      ++ (with pkgs-unstable; [
        #unstable
        ]);
      */
    };

    # NixOS has no programs.nushell module; register the persona's shell in /etc/shells so pkexec/PAM accept it.
    environment.shells =
      [userShell]
      ++ lib.optional (userShell ? shellPath) "${userShell}${userShell.shellPath}";

    assertions = [
      {
        assertion = let
          userShellPath =
            if userShell ? shellPath
            then "/run/current-system/sw${userShell.shellPath}"
            else toString userShell;
          etcShells = lib.splitString "\n" config.environment.etc.shells.text;
        in
          builtins.elem userShellPath etcShells;
        message = "users.users.${username}.shell must be listed in environment.shells (/etc/shells) for pkexec/PAM.";
      }
    ];
  };
}
