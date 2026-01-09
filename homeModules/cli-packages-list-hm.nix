{
  #inputs,
  config,
  #lib,
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages =
    (with pkgs; [
      # stable packages
    ])
    ++ (with pkgs-unstable; [
      #unstable packages

      poppler-utils

      #lsp for code editors
      nixd
      nix

      # terminal apps
      vim
      wget
      #wcurl
      nano
      git-town
      #moar # pager like less but modern
      #btop
      #fastfetch
      #bat # cat modern alternative
      tldr # tldr-update is added in services
      lsd
      rip2
      duf
      ripgrep # grep alternative #rg is the command
      ripgrep-all # same as ripgrep but for many file types like video, PDFs, etc etc
      #nh
      #gg-jj
      #nix-index
      #micro
      wakatime-cli
      nix-output-monitor
    ]);
  #++
  #(lib.optionals (!isDroid) (with pkgs-unstable; [
  #
  #  ]))
}
