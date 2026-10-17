{
  self,
  lib,
  ...
}: {
  flake.nixosModules.tor = {
    config,
    pkgs,
    lib,
    ...
  }: {
    # ---------------------------------------------------------------------------
    # Tor Outbound Client Daemon (Local SOCKS5 Proxy on 127.0.0.1:9050)
    # ---------------------------------------------------------------------------
    services.tor = {
      enable = true;
      client.enable = true; # Local SOCKS5 proxy on 127.0.0.1:9050
    };

    # Declarative torsocks configuration allowing loopback bypass & circuit isolation
    environment.etc."tor/torsocks.conf".text = ''
      TorAddress 127.0.0.1
      TorPort 9050
      AllowOutboundLocalhost 1
      IsolatePID 1
    '';

    # System-wide CLI utilities
    environment.systemPackages = with pkgs; [
      tor
      torsocks
    ];
  };
}
