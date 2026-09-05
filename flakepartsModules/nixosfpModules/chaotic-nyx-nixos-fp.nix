{inputs, ...}: {
  flake-file.inputs = {
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
  };

  # Chaotic-Nyx binary cache
  flake-file.nixConfig = {
    extra-substituters = [
      "https://nyx-cache.chaotic.cx/"
      "https://chaotic-nyx.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nyx-cache.chaotic.cx:dJxTrgMC3V3cFfyIiBQDQorG6k1LsqurH/srpMSq7qk="
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
    ];
  };

  flake.nixosModules.chaotic-nyx = {
    pkgs,
    pkgs-unstable,
    ...
  }: {
    # CachyOS Performance Kernel (Rolling + Clang ThinLTO + BORE)
    boot.kernelPackages = inputs.chaotic.legacyPackages.${pkgs.stdenv.hostPlatform.system}.linuxPackages_cachyos;

    # Sched-ext eBPF scheduler for ultra-low latency desktop interactivity under load
    services.scx = {
      enable = true;
      scheduler = "scx_lavd";
    };

    # Ananicy auto-nice daemon with latest Git rules from Chaotic-Nyx
    services.ananicy = {
      enable = true;
      package = pkgs-unstable.ananicy-cpp;
      rulesProvider = inputs.chaotic.legacyPackages.${pkgs.stdenv.hostPlatform.system}.ananicy-rules-cachyos_git;
    };
  };
}
