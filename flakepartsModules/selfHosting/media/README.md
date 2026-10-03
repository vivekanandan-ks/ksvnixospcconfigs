# Self-Hosted Media Server Stack

This directory contains the declarative media infrastructure for the homelab, shared across all NixOS hosts (`ksvnixospc`, `akashnixospc`, `deejunixospc`) via `flake.nixosModules.selfHosting`.

---

## 1. Service Directory & Port Map

All services bind to the local network interface and have their corresponding TCP ports opened in `networking.firewall.allowedTCPPorts`.

| Service | Port | Web UI URL | Default Credentials | Purpose |
| :--- | :---: | :--- | :--- | :--- |
| **Jellyfin** | `8096` | `http://<host>:8096` | `admin` / `admin123`<br>`user` / `user123` | Central media streaming server for Movies, TV, Anime, and Music. |
| **qBittorrent** | `8282` | `http://<host>:8282` | `admin` / `adminadmin` *(prompted to change)* | Torrent client strictly confined inside WireGuard VPN namespace (`wg`). |
| **FlareSolverr** | `8191` | `http://<host>:8191` | *N/A (API)* | Headless solver proxy to bypass Cloudflare protection on indexers. |
| **Prowlarr** | `9696` | `http://<host>:9696` | Configured on initial launch | Centralized indexer and tracker manager. Syncs to all `*arr` instances. |
| **Radarr** | `7878` | `http://<host>:7878` | Configured on initial launch | Movies management, metadata scraper, and automated downloader. |
| **Sonarr (Standard)** | `8989` | `http://<host>:8989` | Configured on initial launch | Television shows management, season tracking, and downloader. |
| **Sonarr (Anime)** | `8990` | `http://<host>:8990` | Configured on initial launch | Dedicated Anime instance with TRaSH anime release group scoring. |
| **Lidarr** | `8686` | `http://<host>:8686` | Configured on initial launch | Music collection manager; searches trackers and upgrades to FLAC. |
| **Navidrome** | `4533` | `http://<host>:4533` | `admin` / `admin123` | High-performance, Subsonic-compatible dedicated music streaming server. |
| **Seerr** | `5055` | `http://<host>:5055` | Configured via Jellyfin login | 1-click media request portal for family and guests. |
| **Recyclarr** | *N/A* | Background Timer | *N/A (CLI)* | Automatically synchronizes TRaSH Guides quality profiles and regex rules. |

---

## 2. Directory Layout & Storage

All media and persistent state files are structured with uniform permissions under the `media` group:

```
/data/
├── media/
│   ├── movies/      # Radarr & Jellyfin
│   ├── shows/       # Sonarr (Standard) & Jellyfin
│   ├── anime/       # Sonarr (Anime) & Jellyfin
│   └── music/       # Lidarr, Navidrome & Jellyfin
└── torrents/
    ├── incomplete/  # qBittorrent in-progress downloads
    └── complete/    # Downloaded files awaiting hardlinking/import
```

### Storage Backing & Portability
- **Universal Contract:** The shared media stack exclusively references `/data`.
- **Automated Directory Provisioning:** [media-dirs-fp.nix](file:///home/ksvnixospc/Documents/ksvnixospcconfigs/flakepartsModules/selfHosting/media/media-dirs-fp.nix) uses `systemd.tmpfiles.rules` to create all required media and torrent subdirectories on boot with `0775` permissions owned by `${username}:media`.
- **Host-Specific Storage Backing:**
  - On `ksvnixospc`:
    1. **Disko Mount:** The `237GB` partition is mounted to `/mnt/storage/237GB` at boot via [hw-ksvnixospc-fp.nix](file:///home/ksvnixospc/Documents/ksvnixospcconfigs/flakepartsModules/hostsfpModules/ksvnixospc/hw-ksvnixospc-fp.nix).
    2. **Bind Mount:** `/mnt/storage/237GB/selfHost` is bind-mounted directly to `/data` via [storage-ksvnixospc-fp.nix](file:///home/ksvnixospc/Documents/ksvnixospcconfigs/flakepartsModules/hostsfpModules/ksvnixospc/storage-ksvnixospc-fp.nix).
    3. **Zero Root Consumption:** 100% of media and torrent downloads reside on the secondary 237GB drive; 0 bytes are consumed on the root (`/`) filesystem.
  - On other hosts (`akashnixospc`, `deejunixospc`):
    - By default, `/data` is created on root without extra configuration, or each host can bind-mount its own drive to `/data`.

---

## 3. Architecture & Service Breakdown

### Central Streaming: Jellyfin
- **Libraries Configured:**
  - `Movies` $\rightarrow$ `/data/media/movies`
  - `TV Shows` $\rightarrow$ `/data/media/shows`
  - `Anime` $\rightarrow$ `/data/media/anime`
  - `Music` $\rightarrow$ `/data/media/music`
- **100% Direct Play Enforced:**
  - `enableVideoPlaybackTranscoding = false` and `enableAudioPlaybackTranscoding = false` are set declaratively on user accounts.
  - Jellyfin behaves as a high-speed HTTP streamer; decoding is handled 100% on client devices (Kodi, Jellyfin Media Player, Finamp), resulting in near-zero server CPU usage.
- **Hardware Acceleration:**
  - Host-specific Intel Haswell Gen 7.5 VA-API (`/dev/dri/renderD128`) enabled on `ksvnixospc` for thumbnail scrubbing and fallback trickplay.

### Dedicated Music Ecosystem: Navidrome + Lidarr
- **Lidarr (Port 8686):**
  - Manages music metadata, discographies, and automated tracker downloads into `/data/media/music`.
  - Default quality profile uses **Lossless (FLAC)** as the cutoff target, falling back to **MP3-320** if lossless is not yet available, and automatically upgrading when a FLAC release appears.
- **Navidrome (Port 4533):**
  - Ultra-lightweight Subsonic music server (~30MB–50MB RAM, built in Go).
  - Instant library scanning of `/data/media/music`.
  - Seamlessly integrates with dedicated mobile music apps:
    - **Android:** *Symfonium* (recommended), *DSub*, *Substreamer*.
    - **iOS:** *Ampsharp*, *play:Sub*.
    - **Desktop:** *Feishin*, *Sonixd*, or web browser.

### Dedicated Anime vs. Standard TV: Sonarr Dual-Instance
- **Sonarr Standard (Port 8989):** Focuses exclusively on western/standard television shows using TRaSH SQP-1 (1080p) web/bluray releases.
- **Sonarr Anime (Port 8990):** Dedicated instance for Japanese animation with TRaSH scoring:
  - **Top Priority (`+500`):** Japanese Audio / English Soft-subs (SubsPlease, Erai-raws, Commie, Dame-Desu-Yo).
  - **Fallback Priority (`+100`):** Dual Audio (Japanese + English).
  - **Blacklisted (`-10,000`):** English Dubs only / Hardcoded foreign subtitles.
  - **Quality Floor:** Minimum 720p/1080p, rejecting low-bitrate SD rips.

### Torrent Confinement & VPN Killswitch
- **qBittorrent (Port 8282):**
  - Bound strictly inside a WireGuard network namespace (`wg`).
  - Automated `wgcf` key generation bootstrap guarantees zero setup overhead.
  - **Fail-safe Kill Switch:** If the VPN connection drops, torrent network traffic stops instantly. No torrent traffic can leak over the host's cleartext LAN/WAN interfaces.
  - Local Web UI is forwarded through firewall translation so you can access `http://<host>:8282` from your home network without VPN friction.

### Automation & Management
- **Prowlarr (Port 9696):** Synchronizes indexers and download clients across Radarr, Sonarr, Sonarr Anime, and Lidarr in one place.
- **FlareSolverr (Port 8191):** Solves Cloudflare Turnstile/DDoS challenges silently in the background for private and public trackers.
- **Seerr (Port 5055):** User-friendly media discovery and request front-end. Users request titles, and Seerr sends commands to Radarr or Sonarr.
- **Recyclarr:** Periodic systemd timer synchronizing TRaSH Guides formats and size profiles directly into Radarr and Sonarr instances.

---

## 4. Module File Hierarchy

```
flakepartsModules/selfHosting/media/
├── README.md                          # This documentation file
├── jellyfin/
│   ├── jellyfin-core-fp.nix           # Base service & media directory definition
│   ├── jellyfin-encoding-fp.nix       # Intel Haswell VA-API hardware acceleration (host-specific)
│   ├── jellyfin-firewall-fp.nix       # Port 8096 firewall configuration
│   ├── jellyfin-libraries-fp.nix      # Movies, Shows, Anime, and Music library paths
│   └── jellyfin-users-fp.nix          # Declarative user policies (100% Direct Play)
├── music/
│   └── navidrome-fp.nix               # Navidrome Subsonic music server
├── rr/
│   ├── flaresolverr-fp.nix            # FlareSolverr Cloudflare bypass proxy
│   ├── lidarr-fp.nix                  # Lidarr music downloader
│   ├── prowlarr-fp.nix                # Prowlarr indexer synchronizer
│   ├── radarr-fp.nix                  # Radarr movie management
│   ├── recyclarr-fp.nix               # Recyclarr TRaSH sync timer
│   ├── seerr-fp.nix                   # Seerr request UI
│   ├── sonarr-anime-fp.nix            # Dedicated anime instance (Port 8990)
│   └── sonarr-fp.nix                  # Standard TV instance (Port 8989)
└── torrent/
    ├── qbittorrent-fp.nix             # qBittorrent confined inside VPN namespace
    └── wgcf-bootstrap-fp.nix          # Declarative WireGuard key generation
```

---

## 5. Deployment Instructions

To rebuild and activate the media stack on any host:

```bash
# On ksvnixospc:
nh os switch . --hostname ksvnixospc

# On akashnixospc:
nh os switch . --hostname akashnixospc

# On deejunixospc:
nh os switch . --hostname deejunixospc
```
