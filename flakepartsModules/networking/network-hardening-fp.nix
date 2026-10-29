_: {
  flake.nixosModules.networkHardening = {
    # Kernel-level network stack defense against DDoS & spoofing
    boot.kernel.sysctl = {
      # Cryptographic SYN cookies against TCP SYN floods
      "net.ipv4.tcp_syncookies" = 1;
      # Loose reverse path filtering (drops spoofed packets while permitting NetBird/mesh routing)
      "net.ipv4.conf.all.rp_filter" = 2;
      "net.ipv4.conf.default.rp_filter" = 2;
      # Ignore ICMP broadcast pings (Smurf amplification protection)
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      # Refuse ICMP routing redirects (prevents route poisoning)
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
    };
  };
}
