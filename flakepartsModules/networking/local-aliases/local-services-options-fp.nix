_: {
  flake.nixosModules.localServices = {lib, ...}: {
    options.localServicesPorts = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = {};
      description = "Mapping of service names to port configurations and metadata ({ proxyPort, listenPort?, title?, category?, role? }).";
      example = {
        navidrome = { proxyPort = 4533; category = "Music"; role = "user"; };
        sonarr = { proxyPort = 8989; category = "Automation"; role = "admin"; };
      };
    };

    options.localServicesSecuritySnippet = lib.mkOption {
      type = lib.types.lines;
      default = ''
        header {
          X-Content-Type-Options "nosniff"
          X-Frame-Options "SAMEORIGIN"
          Referrer-Policy "strict-origin-when-cross-origin"
          Permissions-Policy "camera=(), microphone=(), geolocation=(), payment=()"
          -Server
        }

        @scrapers header_regexp User-Agent "(?i)(claudebot|bytespider|gptbot|ccbot|anthropic|petalbot|semrushbot|ahrefsbot)"
        handle @scrapers {
          abort
        }
      '';
      description = "Shared Caddy configuration snippet for security headers and bot protection.";
    };
  };
}
