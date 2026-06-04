# Time Server (Flutter, Android)

A Flutter Android port of the PublicNTP **time-server-app**: turn your phone/tablet
into a **GPS-disciplined SNTP/NTP time server** so local-network devices (ESP32,
Linux, Windows, IoT) can sync time from it. Faithful re-creation of the original
UI, GNSS view, and server behaviour.

## Features

- **Time tab** — GPS time vs device clock with live `±x.xx sec` offset; location in
  WGS84 / UTM / MGRS / OLC; UTC / Local / Decimal / Swatch time standards; open in
  Maps / copy to clipboard.
- **Satellites tab** — in-view / in-use counts, radial sky plot (azimuth/elevation,
  Cn0-shaded, triangle = used in fix), tappable signal-strength bars, per-satellite
  detail (constellation, SNR, elevation, azimuth, carrier band), compass heading.
- **Server tab** — SNTP on/off switch, live packets/min chart (in = purple,
  out = green), interface/IP/port readout; stratum (1–4), interface, throttle, and
  auto-start options.
- **About tab** — version, license, credits, donate link.
- Foreground service + partial wake lock + battery-optimization exemption so the
  server keeps running in the background. Optional root `iptables` 123→1234 redirect.
- Localised: en, fr, es, de, pt, ja, da, nb, no, sv.

## ⚠️ Important: which port clients use

A normal (non-root) Android app **cannot bind the privileged NTP port 123**, so the
server listens on **UDP 1234**. Point clients at `PHONE_IP:1234`.

- **Rooted device:** toggling the server attempts an `iptables` redirect so clients
  can also use the standard port **123**.
- Clients that hard-code port 123 (some ESP32 SNTP setups, Windows `w32tm`) can only
  sync to a **rooted** phone, or must be configured to use port 1234.

## Build & run

Requires Flutter (3.24+) and the Android SDK.

```bash
flutter pub get
flutter run                 # debug on a connected device
flutter build apk --release # release APK -> build/app/outputs/flutter-apk/
```

> Grant **Location** (for GPS time + satellites) and **Notifications** (for the
> foreground-service notification, Android 13+) when prompted.

## Testing the NTP server

With the phone and a client on the same Wi‑Fi / hotspot:

```bash
# Linux
sntp -d <PHONE_IP> -p 1234
ntpdate -q -u <PHONE_IP>          # if the client allows a custom port

# ESP32 (Arduino / ESP-IDF SNTP)
sntp_setservername(0, "<PHONE_IP>");   # use port 1234 unless the phone is rooted

# Windows (port 123 only -> phone must be rooted/redirected)
w32tm /stripchart /computer:<PHONE_IP> /samples:5
```

Unit tests (NTP codec, epoch conversion, OLC):

```bash
flutter test
```

## Architecture

- **Flutter / Dart** — all UI (Riverpod state), the NTP 48-byte codec, packet log
  buckets, coordinate math (UTM/MGRS/OLC), charts (`fl_chart`), localization.
- **Native Kotlin** (`android/app/src/main/kotlin/app/timeserver/`) — the parts
  Flutter can't reach:
  - `ntp/NtpServerManager` — the UDP server (binds 1234, builds GPS-timed replies).
  - `ntp/NtpForegroundService` — foreground service, wake lock, notification, Stop
    action, connectivity refresh.
  - `ntp/PortForwarding` — optional root 123→1234 redirect.
  - `gnss/GnssController` — `LocationManager` + `GnssStatus` (Cn0/az/el/usedInFix) +
    compass; feeds GPS time to the server and the UI via Event/Method channels.
  - `net/NetworkController`, `power/PowerController` — interfaces/IP, battery exemption.

See `../FLUTTER_MIGRATION_BLUEPRINT.md` for the full design rationale.

## Accuracy note

`Location.getTime()` and the system clock are millisecond-resolution, so realistic
LAN sync is ~1–30 ms despite the packet advertising sub-ms precision. With no GPS
fix the server falls back to system time and advertises reference id `LOCL`.
