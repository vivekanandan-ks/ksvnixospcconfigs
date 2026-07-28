settings = {

        add_newline = false;

        format = ''
          $shell $nix_shell $directory $git_branch $git_status $package $cmd_duration
          $character
        '';

        character = {
          success_symbol = "[>>>](bold fg:green) ";
          error_symbol = "[>>>](bold fg:red) ";
        };

        package = {
          disabled = false;
        };

        scan_timeout = 10;
  
      };