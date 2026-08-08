_: {
  flake.nixosModules.virtual-terminal = {
    # High-resolution TTY console with mouse support and UTF-8
    services.kmscon = {
      enable = true;
      config.mouse = true;
    };
  };
}
