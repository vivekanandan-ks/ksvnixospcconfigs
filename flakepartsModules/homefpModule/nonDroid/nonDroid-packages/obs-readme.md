# OBS Studio Configuration & Optimization Guide

Comprehensive guide for low-CPU, high-quality desktop recording and streaming across NixOS hosts.

---

## 1. Golden Settings Cheatsheet

Open OBS → **Settings** and set the following:

### A. Output Settings (`Settings` → `Output`)

- **Output Mode:** `Advanced`
- **Tab:** `Recording`
  - **Recording Format:** `Matroska (.mkv)` _(crash-proof, zero background fragmenting overhead)_
  - **Video Encoder:** `FFmpeg VAAPI H.264` _(hardware encoding on GPU ASIC; near 0% CPU)_
  - **VAAPI Device:** Default or `/dev/dri/renderD128`
  - **Rate Control:** `CQP`
  - **QP:** `23` _(crisp terminal/code text; 30–40% smaller files)_
  - **Audio Encoder:** `FFmpeg PCM (16-bit)` _(0.0% CPU uncompressed audio)_ or `FFmpeg AAC` (160 kbps)

---

### B. Video Settings (`Settings` → `Video`)

- **Common FPS Values:** `30` _(cuts capture load by 50% vs 60 FPS; perfect 60Hz screen sync with zero judder)_
- **Downscale Filter:** `Bicubic (16 samples)` or `Lanczos (36 samples)`
- **Resolutions:** See host reference table below.

---

## 2. Host-by-Host Reference Table

| Host                                | Hardware                 | Driver     | Resolution (Base / Output)        | Notes                                                                       |
| :---------------------------------- | :----------------------- | :--------- | :-------------------------------- | :-------------------------------------------------------------------------- |
| **`deejunixospc`** _(Intel Laptop)_ | Intel i5-7200U (HD 620)  | `iHD`      | `1366x768` / **`1364x768`**       | Laptop LCD. Output uses Mod-4 width (`1364`).                               |
| **`ksvnixospc`** _(Haswell Laptop)_ | Intel i7-4500U (HD 4400) | `i965`     | `1366x768` / **`1364x768`**       | **Do NOT use HEVC** (Haswell has no hardware HEVC encoder). Stick to H.264. |
| **`akashnixospc`** _(AMD Desktop)_  | AMD Ryzen (Radeon 610M)  | `radeonsi` | **`1920x1080`** / **`1920x1080`** | 1080p monitor. Divisible by 16; no 2-pixel trimming required.               |

> [!NOTE]
> **The "1364 vs 1366" Mod-4 Rule:** Video codecs divide frames into 4x4 or 16x16 macroblocks. `1366` is not divisible by 4, which can crash hardware encoders or produce a vertical green artifact line. `1364` is cleanly divisible by 4 (`1364 / 4 = 341`). Always keep the output width at `1364` on 768p laptops.

---

## 3. Broadcast-Quality Voice Mic (Near 0% CPU)

Connect your Android mic (over USB / Wi-Fi via PipeWire). In the OBS **Audio Mixer**, click `⋮` on the Mic → **Filters**, and add these in order:

1. **Noise Suppression:** `RNNoise` _(eliminates keyboard clatter and laptop fan hum)_
2. **Noise Gate:** _(default thresholds; automatically mutes mic when silent)_
3. **Compressor:** _(default settings; prevents clipping and levels volume)_
4. **3-Band Equalizer:**
   - **Low:** `+2.5 dB` to `+3.0 dB` _(adds rich podcast/radio warmth)_
   - **High:** `-2.0 dB` _(de-essing: tames harsh 'S' sounds)_

---

## 4. Performance Checklist for Laptops

- [ ] **Disable Live Preview:** While recording, right-click the central OBS canvas → uncheck **Enable Preview**. Saves significant rendering cycles on dual-core CPUs.
- [ ] **Avoid Hybrid MP4:** Always record to `.mkv`. If you need `.mp4`, enable _Automatically remux to mp4_ in `Settings` → `Advanced`, or use `File` → `Remux Recordings` (takes 1 second).

---

## 5. YouTube Upscale Trick (Post-Processing)

YouTube degrades 720p/768p videos with an aggressive, blurry codec (`avc1`). Keep your laptop cool by recording natively at 768p, then run this GPU-accelerated FFmpeg command to upscale to 1080p before uploading:

```bash
ffmpeg -vaapi_device /dev/dri/renderD128 -i input.mkv \
  -vf 'format=nv12,hwupload,scale_vaapi=w=1920:h=1080' \
  -c:v h264_vaapi -qp 20 -c:a copy output-1080p.mp4
```
