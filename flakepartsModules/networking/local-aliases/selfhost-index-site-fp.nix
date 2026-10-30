_: {
  flake.nixosModules.localServices = {
    config,
    lib,
    pkgs,
    ...
  }: let
    services = config.localServicesPorts;
    hasServices = services != {};

    portalPort = 18000;

    # Render a simple <ul> list for a set of services
    renderList = sMap:
      lib.concatStringsSep "\n" (lib.mapAttrsToList (name: s:
        let
          listenPort = s.listenPort or (s.proxyPort + 10000);
          title = s.title or name;
          category = s.category or "";
          catSpan = if category != "" then "<span>(${category})</span>" else "";
        in
          "    <li><a data-port=\"${toString listenPort}\" href=\"#\">${title}</a> ${catSpan}</li>"
      ) sMap);

    userServices = lib.filterAttrs (_: s: (s.role or "user") == "user") services;
    adminServices = lib.filterAttrs (_: s: (s.role or "user") == "admin") services;

    # Minimal static HTML generated in the Nix store (zero external fonts)
    portalHtml = pkgs.writeTextDir "index.html" ''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Services</title>
        <style>
          body { font-family: sans-serif; margin: 2rem auto; max-width: 600px; background: #111; color: #ddd; }
          h1 { border-bottom: 1px solid #333; padding-bottom: 0.5rem; }
          h2 { color: #8ab4f8; margin-top: 1.5rem; font-size: 1.1rem; }
          ul { list-style: none; padding-left: 0; }
          li { margin: 0.6rem 0; }
          a { color: #81c995; text-decoration: none; font-weight: bold; font-size: 1.05rem; }
          a:hover { text-decoration: underline; }
          span { color: #888; font-size: 0.85rem; margin-left: 0.5rem; }
        </style>
      </head>
      <body>
        <h1>Homelab</h1>

        <h2>User Services</h2>
        <ul>
      ${renderList userServices}
        </ul>

        <h2>Admin Services</h2>
        <ul>
      ${renderList adminServices}
        </ul>

        <script>
          document.querySelectorAll('a[data-port]').forEach(a => {
            a.href = 'https://' + window.location.hostname + ':' + a.dataset.port;
          });
        </script>
      </body>
      </html>
    '';
  in {
    config = lib.mkIf hasServices {
      # Caddy serves the portal directly from the Nix store
      services.caddy.virtualHosts."https://:${toString portalPort}" = {
        extraConfig = ''
          # Homelab Portal
          tls internal {
            protocols tls1.3
          }

          ${config.localServicesSecuritySnippet}

          root * ${portalHtml}
          file_server
        '';
      };

      # Allow local Wi-Fi and NetBird to reach the portal (with connection limit)
      networking.firewall.extraCommands = ''
        iptables -A nixos-fw -p tcp --dport ${toString portalPort} -m connlimit --connlimit-above 80 -j REJECT
        iptables -A nixos-fw -p tcp --dport ${toString portalPort} -s 192.168.0.0/16 -j nixos-fw-accept
        iptables -A nixos-fw -p tcp --dport ${toString portalPort} -s 10.0.0.0/8 -j nixos-fw-accept
        iptables -A nixos-fw -p tcp --dport ${toString portalPort} -s 100.64.0.0/10 -j nixos-fw-accept
      '';
    };
  };
}
