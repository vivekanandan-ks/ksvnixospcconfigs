{self, ...}: {
  flake.nixosModules.users = {
    pkgs-unstable,
    username,
    ...
  }: {
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
      ];
      hashedPassword = "$6$DmrUUL7YWFMar6aA$sAoRlSbFH/GYETfXGTGa6GSTEsBEP1lQ6oRdXlQUsqhRB7OTI2vTmVlx64B2ihcez8B0q0l8/Vx1pO8c82bxm0";
      shell = self.personas.ksv.personalShell pkgs-unstable;
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
  };
}
