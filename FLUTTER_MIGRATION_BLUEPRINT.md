# PublicNTP **time-server-app** → Flutter Migration Blueprint

> Analysis-only document. No Flutter code is written yet. This is the complete
> migration plan derived from a file-by-file reading of the original Java/Android
> source (`app.timeserver`, versionName `1.0.30`, minSdk 24 / targetSdk 28).

---

## 1. Executive Summary

`time-server-app` turns an Android phone/tablet into a **GPS-disciplined SNTP/NTP
time server**. It reads time from the GPS subsystem (`Location.getTime()`),
displays a live comparison between GPS time and the device clock, shows the GNSS
satellite constellation (radial sky plot + signal bars), and runs a **UDP NTP
server** so that other devices on the local network (ESP32, Linux, Windows, IoT)
can synchronize their clocks from the phone.

The single most important technical fact for the migration:

- **The UDP server actually binds to port `1234` (`NTP_UNRESTRICTED_PORT`)**, not
  the standard NTP port `123`. Port `123` is only reachable when the device is
  **rooted**, via an `iptables` PREROUTING REDIRECT 123→1234 installed through
  `libsuperuser`. On a non-rooted device, clients must talk to `:1234`.
- The time placed in NTP replies is **GPS-derived** time from
  `TimeStorageConsumer.getTime()`, falling back to system time when there is no
  fix. Reference ID is `"GPS"` (`0x47505300`), default stratum `1`.

A Flutter rebuild is **feasible and largely faithful**. The UI, NTP packet
codec, coordinate math, and even the UDP socket can be Dart. What *must* stay
native (Kotlin platform channels) is: the **GNSS satellite status stream**
(`GnssStatus` Cn0/az/el/usedInFix), the **foreground service + partial wake lock
+ battery-optimization exemption**, and the optional **root `iptables`
redirect**. GPS time and Wi‑Fi IP can be plugins but are best kept native to feed
the server precisely.

---

## 2. Original App Feature List

1. **GPS vs device-clock comparison** — live time display with a `±x.xx sec`
   offset (Time tab).
2. **Location readout** — lat/long with accuracy, convertible to WGS84 / UTM /
   MGRS / OLC (Plus Codes); "Open in Maps" and "Copy to clipboard".
3. **Time standard selection** — UTC / Local / Decimal time / Swatch Internet
   Time. Measurement units Metric/Imperial.
4. **GNSS satellite view** — count "in view" / "in use", radial sky plot
   (azimuth/elevation, signal-shaded, triangle=used / square=unused), tappable
   signal-strength bar chart, per-satellite detail (constellation, SNR,
   elevation, azimuth, carrier band L1/L2/L5…), optional compass rotation.
5. **SNTP/NTP server** — on/off switch; serves GPS time over UDP; live packets/min
   column chart (incoming purple / outgoing green); shows interface + IP + port.
6. **Server configuration** — stratum (1–4), network interface (eth0/wlan0/usb0),
   throttle (packets/min), auto-start on launch.
7. **Foreground service** — persistent notification ("NTP Server Running",
   interface/IP/port), "Stop NTP Server" action; partial wake lock; battery
   optimization exemption prompt.
8. **Root enhancement** — `iptables` redirect so standard clients can use port
   123; warns "works best with a rooted device" otherwise.
9. **Splash screen** — animated PublicNTP GIF for ~6 s, starts location updates.
10. **About** — version, MIT license, credits, donate/visit snackbar.
11. **Localization** — en, fr, es, de, pt, ja, da, nb, no, sv.

---

## 3. Original Repository Structure

```
time-server-app/
├── build.gradle                 # AGP 3.3.1; minSdk24 targetSdk28 compileSdk28
├── app/build.gradle             # dagger, butterknife, commons-net, hellocharts,
│                                #   android-gif-drawable, libsuperuser, guava, timber
├── app/proguard-rules.pro
├── app/release/                 # prebuilt app-v1.0.30 apk/aab (reference binaries)
└── app/src/main/
    ├── AndroidManifest.xml
    ├── java/app/timeserver/
    │   ├── TimeServerApplication.java        # Timber init
    │   ├── ui/
    │   │   ├── SplashActivity.java           # 6s GIF, start location
    │   │   ├── MainActivity.java             # TabLayout + ViewPager (4 tabs)
    │   │   ├── BaseFragment.java             # setRetainInstance(true)
    │   │   ├── time/TimeFragment.java
    │   │   ├── time/OptionsDialogFragment.java
    │   │   ├── satellite/SatelliteFragment.java
    │   │   ├── satellite/SatelliteRadialChart.java   # custom View sky-plot
    │   │   ├── satellite/SignalGraphFragment.java     # hellocharts bars
    │   │   ├── satellite/SatelliteDetailFragment.java
    │   │   ├── server/ServerFragment.java
    │   │   ├── server/ServerDialogFragment.java
    │   │   └── about/AboutFragment.java
    │   ├── service/ntp/
    │   │   ├── NtpService.java               # foreground Service, wake lock, FGS
    │   │   ├── SimpleNTPServer.java          # UDP server loop (commons-net NtpV3)
    │   │   ├── NtpMessage.java / NtpMessageJ2ME.java   # raw 48-byte codec (test)
    │   │   ├── SntpClient.java               # desktop test client (main())
    │   │   ├── PortForwardingHelper.java     # root iptables redirect
    │   │   ├── KillServiceReceiver.java      # notification "stop" action
    │   │   ├── NetworkChangeReceiver.java    # rebuild notification on net change
    │   │   └── logging/                      # ServerLogDataPoint(+Grouper, MinuteSummary)
    │   ├── listener/
    │   │   ├── LocationHelper.java           # requestLocationUpdates + GnssStatus cb
    │   │   └── SatelliteLocationListener.java
    │   ├── repository/
    │   │   ├── time/TimeStorage.java         # GPS time + drift adjust (static)
    │   │   ├── time/TimeStorageConsumer.java
    │   │   └── location/ (+ converters UTM/MGRS/OLC/LatLong)
    │   ├── model/SatelliteModel.java
    │   └── helper/
    │       ├── NetworkInterfaceHelper.java   # enumerate ifaces, IPv4 for name
    │       ├── TimeMillis.java
    │       ├── DateFormatter.java
    │       ├── GreyLevelHelper.java          # Cn0 → grey shade
    │       ├── permissions/ (PermissionsHelper, Permission)
    │       └── preferences/ (SharedPreferences stores)
    ├── java/gov/nasa/worldwind/…             # bundled UTM/MGRS coordinate math
    ├── java/com/google/openlocationcode/…    # Plus Codes (OLC)
    ├── java/com/berico/coords/…              # coordinate helpers
    └── res/                                  # layouts, drawables, 10 locales, arrays
```

Third-party code is vendored (NASA WorldWind, Open Location Code, berico) for
coordinate conversion only — not central to time-serving.

---

## 4. File-by-File Analysis

For each file: **Purpose / Key elements / Migration target.** Targets are coded:
🟦 Pure Dart · 🟩 Flutter plugin · 🟥 Native Kotlin channel · ⛔ Needs root/system.

### 4.1 Manifest & Build

**`AndroidManifest.xml`** — Declares 8 permissions (COARSE/FINE location,
INTERNET, ACCESS_NETWORK_STATE, ACCESS_WIFI_STATE, WAKE_LOCK, FOREGROUND_SERVICE,
REQUEST_IGNORE_BATTERY_OPTIMIZATIONS). `SplashActivity` is LAUNCHER (SplashTheme);
`MainActivity` portrait-locked. `KillServiceReceiver` listens for action
`KILL_NTP_SERVICE`. `NtpService` declared `exported="true"`. (Note: a stray
`<receiver .service.ntp.ServerActivity>` references a non-existent class — dead
entry.)
→ 🟥 Recreate as the Flutter app's manifest; add modern FGS requirements (see §13).

**`app/build.gradle`** — DataBinding + ButterKnife + Dagger; `commons-net:3.6`
(NTP), `hellocharts` (charts), `android-gif-drawable` (GIFs), `libsuperuser`
(root), `guava` (RateLimiter), `timber` (logging).
→ Replace with Flutter `pubspec.yaml` deps (§7) + a slim Kotlin module.

**`build.gradle`** — AGP 3.3.1, minSdk 24, target/compile 28.
→ Modernize: AGP 8.x, compile/target 34/35, minSdk 24 (or 26).

### 4.2 NTP Service Layer (the core)

**`NtpService.java`** (Android `Service`) — The heart.
- Constants `NTP_DEFAULT_PORT=123`, `NTP_UNRESTRICTED_PORT=1234`.
- `onCreate`/`onStartCommand` → `BeginNTPService()` (idempotent via `started`),
  returns `START_STICKY`.
- `BeginNTPService()`: spins a thread that builds `SimpleNTPServer(1234)` and
  `.start()`; calls `tryForwardPorts()`; enumerates eth0/wlan0/usb0 into
  `portList`; **acquires `PARTIAL_WAKE_LOCK`**; on API ≥ M fires
  `ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` if not already exempt;
  `startForeground(1, notification)`; registers `NetworkChangeReceiver`; broadcasts
  `START_NTP_SERVICE`.
- `buildNotification()`: channel `NTP_SERVICE`, title `server_running`, content
  `interface, ip:port`, action → `KillServiceReceiver`. Chooses interface
  eth0→wlan0→usb0 and resolves IP via `NetworkInterfaceHelper`.
- `tryForwardPorts()`: if `Shell.SU.available()` → `PortForwardingHelper` enables
  forwarding + `iptables` redirect 123→1234; sets `rootRedirected`.
- Mutators called from dialog: `changeNetwork`, `setStratumNumber`,
  `limitPackets`, `changePort`; `onDestroy` releases wake lock, stops server,
  unregisters receiver.
- Static singleton (`getNtpService`, `exists`).
→ 🟥 Becomes a Kotlin foreground service (`NtpForegroundService`) exposed through
platform channels; wake lock, notification, battery prompt, root redirect stay
native. The socket loop can be Kotlin **or** a Dart background isolate (§6, §7).

**`SimpleNTPServer.java`** (UDP server, adapted from Apache Commons-Net) —
- Binds `DatagramSocket(port=1234)`; 48-byte buffer; `run()` loop:
  `socket.receive()` → `rcvTime = timeStorageConsumer.getTime()` → `handlePacket`.
- `handlePacket`: logs inbound; parses `NtpV3Impl`; if `MODE_CLIENT`, builds
  reply: `stratum`(config), `MODE_SERVER`, `VERSION_3`, `precision=-20`,
  `poll=0`, `rootDelay=62`, `rootDispersion=(int)(16.51*65.536)=1082`,
  `referenceId=0x47505300 ("GPS")`; **originate=client transmit (t1)**,
  **receive=NTP(rcvTime) (t2)**, reference=receive, **transmit=NTP(appTime)
  (t3)**; sends to client addr/port; logs outbound.
- Known bugs to fix in the rewrite: a fresh Guava `RateLimiter` is created per
  packet (throttle effectively non-functional); `setPacketSize` calls
  `rateLimiter.create()` on a null field (would NPE).
→ 🟦 Reimplement the loop + codec in Dart (`RawDatagramSocket`) — fully portable;
keep parsing/serialization in a tested Dart `NtpPacket` class.

**`NtpMessage.java` / `NtpMessageJ2ME.java`** — Adam Buckley's raw 48-byte NTP
codec; used by the test `SntpClient`. Documents the exact wire format, the NTP
epoch offset `2208988800.0`, and 16.16/32.32 fixed-point fields. (Bug: random
low-order byte writes `array[7]` instead of `array[pointer+7]`.)
→ 🟦 Port to Dart as the canonical codec; fix the byte bug; unit-test against it.

**`SntpClient.java`** — Desktop `main()` NTP client (RFC 2030 offset/round-trip).
→ 🟦 Optional Dart CLI/test helper; not shipped in the app.

**`PortForwardingHelper.java`** — Root `iptables -t nat -I PREROUTING -p udp
--dport 123 -j REDIRECT --to-port 1234` + enables per-iface forwarding via
`/proc/sys/net/ipv4/conf/*/forwarding`, all through `Shell.SU`.
→ ⛔ Native Kotlin + `libsuperuser` (or `su -c`); only works rooted.

**`KillServiceReceiver.java`** — Broadcast receiver; notification "Stop" →
`stopSelf()`.
→ 🟥 Native (notification action inside the FGS).

**`NetworkChangeReceiver.java`** — On `CONNECTIVITY_ACTION` → rebuild notification
(refresh IP/interface).
→ 🟥 Native `ConnectivityManager.NetworkCallback`; push IP changes to Dart via
EventChannel.

**`logging/ServerLogDataPoint(+Grouper, MinuteSummary)`** — In-memory `TreeSet`
of `{timeReceived, DatagramPacket, isInbound}`; `mostRecent()` = last minute,
`oneHourSummary()` = 60 one-minute buckets of inbound/outbound counts (chart
feed). (`cleanOld()` is disabled — caused an after-an-hour crash; unbounded
growth is a latent leak.)
→ 🟦 Reimplement in Dart as a ring buffer / time-bucketed counters; fix the leak.

### 4.3 Time & Location Repository

**`TimeStorage.java`** (static) — `setMillis(gpsMillis)` stores `satelliteDate`
plus `acquiredDate=now`. `getAdjustedMillis()=satelliteDate+(now−acquiredDate)`;
**falls back to `System.currentTimeMillis()` when no fix**. `getDateDifference()`
= `|satelliteDate−acquiredDate|` (the displayed offset). `getTime()` feeds the
server.
→ 🟥 Keep a native time provider (fed by GPS) to serve precise time; mirror to
Dart for UI. Logic itself is 🟦 trivial to port.

**`TimeStorageConsumer.java`** — UI/server-facing wrapper; formats offset
`±%.2f`, gates display on `NtpService.exists()`.
→ 🟦 Dart view-model.

**`repository/location/*` + converters (`LatLong/UTM/MGRS/OLC`)** — Stores
`Location`, builds satellite list from `GnssStatus`, converts coordinates using
bundled WorldWind/OLC.
→ 🟦 Dart: `mgrs_dart`, `utm`, `open_location_code`, manual lat/long formatting.

### 4.4 GPS / GNSS Listeners & Model

**`LocationHelper.java`** — `requestLocationUpdates(GPS_PROVIDER, 10ms, 0m, l)` +
`registerGnssStatusCallback(l)`. **Misnamed**: no NMEA is parsed; time is plain
`Location.getTime()`.
→ 🟥 Native `LocationManager`/GnssStatus channel (plugins don't expose Cn0/az/el).

**`SatelliteLocationListener.java`** — `onLocationChanged`→`TimeStorage.setMillis`
+ `LocationStorage.setLocation`; `onSatelliteStatusChanged`→
`LocationStorage.setSatelliteList`.
→ 🟥 Native; emit GPS-time + satellite events to Dart via EventChannels.

**`SatelliteModel.java`** — Per-satellite: `svid`, `constellationType`(+name
GPS/GLONASS/GALILEO/BEIDOU/QZSS/SBAS), `Cn0DbHz`, `elevationDegrees`,
`azimuthDegrees`, `usedInFix`, `ephemeris/almanac`, `carrierFrequencyMhz`
(API ≥ 27) with band label L1/L2/L5/E1/E5/B1/B2.
→ 🟦 Dart data class (built from channel maps).

### 4.5 UI Layer (see §10 for full screen plan)

**`SplashActivity`** 🟦/🟥 — 6 s GIF; checks FINE_LOCATION; starts location → Main.
**`MainActivity`** 🟦 — `TabLayout`+`ViewPager`, custom tabs, 4 fragments order
**Time(0) · Satellites(1) · Server(2) · About(3)**; `autoStart` pref selects
Server tab; requests FINE_LOCATION.
**`BaseFragment`** 🟦 — retain instance.
**`TimeFragment` / `OptionsDialogFragment`** 🟦 — time/offset/location + options.
**`SatelliteFragment` / `RadialChart` / `SignalGraph` / `DetailFragment`** 🟦
(chart) + 🟥 (data) — sky plot (`CustomPaint`), bars (`fl_chart`), detail, compass.
**`ServerFragment` / `ServerDialogFragment`** 🟦 UI + 🟥 service control — switch,
packets/min chart, port/interface text, stratum/iface/packet/auto-start options.
**`AboutFragment`** 🟦 — version, credits, donate snackbar.

**`helper/*`** — `NetworkInterfaceHelper` (🟩 `network_info_plus` or 🟦
`NetworkInterface.list()`), `GreyLevelHelper` (🟦 Cn0→shade), `DateFormatter` (🟦
`intl`), `permissions/*` (🟩 `permission_handler`), `preferences/*` (🟩
`shared_preferences`).

**`TimeServerApplication`** — Timber init → 🟦 Dart `logging`/`logger`.

---

## 5. Flutter Migration Feasibility Table

| Capability | Classification | Implementation |
|---|---|---|
| NTP 48-byte packet parse/build | 🟦 Pure Dart | `NtpPacket` codec (port `NtpMessage`) |
| Unix↔NTP epoch conversion | 🟦 Pure Dart | `+2208988800` s, 64-bit fixed point |
| UDP socket server (bind **1234**) | 🟦 Pure Dart | `RawDatagramSocket.bind` in bg isolate |
| Bind privileged port **123** | ⛔ Root only | `iptables` redirect (native + su) |
| Per-minute packet logs/chart data | 🟦 Pure Dart | time-bucketed counters |
| Wi‑Fi / interface IP detection | 🟩 Plugin / 🟦 | `network_info_plus` / `NetworkInterface.list` |
| Foreground service (continuous) | 🟥 Native | Kotlin FGS / `flutter_background_service` |
| Partial wake lock | 🟥 Native | `PowerManager.WAKE_LOCK` in FGS |
| Battery-optimization exemption | 🟥 Native | `ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` |
| Persistent notification + action | 🟥/🟩 | part of FGS / `flutter_local_notifications` |
| GPS time (`Location.getTime`) | 🟥 (pref) / 🟩 | native channel feeds server; or `geolocator` |
| **GNSS sat status (Cn0/az/el/usedInFix)** | 🟥 Native | `GnssStatus` EventChannel (no plugin) |
| Carrier frequency / band (API 27+) | 🟥 Native | `GnssStatus.getCarrierFrequencyHz` |
| Compass rotation of sky plot | 🟩 Plugin | `flutter_compass` / `sensors_plus` |
| Radial sky plot rendering | 🟦 Pure Dart | `CustomPaint` |
| Signal/packets bar charts | 🟩 Plugin | `fl_chart` |
| Coordinate conv. UTM/MGRS/OLC | 🟦 Pure Dart | `utm`, `mgrs_dart`, `open_location_code` |
| Animated GIF splash/logo | 🟩 built-in | `Image.asset` (Flutter decodes GIF) |
| Runtime permissions | 🟩 Plugin | `permission_handler` |
| Preferences | 🟩 Plugin | `shared_preferences` |
| Open Maps / clipboard / share | 🟩 Plugin | `url_launcher`, `flutter/services` |
| Localization (10 locales) | 🟩 built-in | `flutter_localizations` + ARB |

**Bottom line:** ~70% pure Dart/plugins; the irreducible native core is GNSS
status, the foreground-service lifecycle (wake lock, notification, battery), and
the optional root redirect.

---

## 6. Native Android Requirements (what cannot be pure Flutter)

1. **GNSS satellite status stream** — `LocationManager.registerGnssStatusCallback`
   / `GnssStatus` exposes Cn0DbHz, azimuth, elevation, constellation, usedInFix,
   carrier frequency. **No Flutter plugin surfaces these**, so a Kotlin
   `EventChannel` is mandatory.
2. **Foreground service lifecycle** — to keep the UDP server alive when
   backgrounded/screen-off you need a real Android foreground service with a
   persistent notification. Pure Dart isolates are paused in the background; only
   a foreground service (native, or via `flutter_background_service` which hosts a
   Dart isolate inside one) survives.
3. **Partial wake lock** — `PowerManager.PARTIAL_WAKE_LOCK` keeps the CPU running
   for the socket. Native.
4. **Battery-optimization exemption** — `Settings.ACTION_REQUEST_IGNORE_BATTERY_
   OPTIMIZATIONS`. Native intent.
5. **Privileged port 123 redirect** — root `iptables`. Native + `su`. ⛔ otherwise.
6. **GPS time as the server's clock** — best read natively (in the same process
   as the socket) so replies use a single coherent time source.
7. **Connectivity changes** — `ConnectivityManager.NetworkCallback` to refresh IP.

Everything else (UI, charts, NTP codec, the socket itself, coordinate math) can be
Flutter/Dart.

**Server-host decision (important):** two viable designs —
- **(A) Native-hosted socket (recommended for fidelity/reliability):** the UDP
  receive/respond loop runs in **Kotlin inside the foreground service**, using a
  native GPS time provider. Dart drives start/stop/config and renders logs via
  channels. Most robust; closest to original; survives background reliably.
- **(B) Dart-hosted socket:** UDP server runs in a **Dart background isolate**
  started by `flutter_background_service` (which itself is a native FGS). Maximizes
  shared Dart code (one `NtpPacket` codec for server + tests) but depends on the
  plugin keeping the isolate alive and on bridging GPS time into that isolate.

This blueprint recommends **(A)** for the shipping server, while still building a
**pure-Dart `NtpPacket` codec** that both the (optional) Dart server and the unit
tests use. (B) is a fallback if you want to avoid Kotlin socket code.

---

## 7. Flutter Architecture

**State management: Riverpod** (chosen). Justification: the app is a set of
independent live streams (GPS time tick, satellite list, server status, packet
log) feeding multiple screens — Riverpod's `StreamProvider`/`NotifierProvider`
model these cleanly, gives compile-safe DI (replacing Dagger), is testable
without a `BuildContext`, and avoids Provider's nesting and BLoC's boilerplate for
what are mostly value streams. (Plain `ChangeNotifier` would work but scales worse
across the 4 tabs + service bridge.)

```
lib/
├── main.dart                      # ProviderScope, theme, localization, router
├── app.dart                       # MaterialApp + splash→shell
├── constants/
│   ├── ntp_constants.dart         # PORT_DEFAULT=123, PORT_UNRESTRICTED=1234,
│   │                              #   NTP_EPOCH_OFFSET=2208988800, REF_ID 'GPS'
│   ├── colors.dart  theme.dart  strings.dart
├── models/
│   ├── ntp_server_status.dart  gps_time_info.dart  satellite_info.dart
│   ├── network_info.dart  ntp_request_log.dart  app_settings.dart
├── core/ntp/
│   ├── ntp_packet.dart            # 🟦 48-byte codec (the canonical implementation)
│   ├── ntp_time.dart              # 🟦 epoch + fixed-point conversion
│   └── dart_ntp_server.dart       # 🟦 optional Dart UDP server (design B)
├── services/
│   ├── ntp_server_service.dart    # facade over native channel (start/stop/config)
│   ├── gnss_service.dart          # satellite stream (EventChannel)
│   ├── gps_time_service.dart      # gps-time/offset stream
│   ├── network_service.dart       # interfaces + IP
│   ├── power_service.dart         # wakelock + battery exemption
│   └── settings_service.dart      # shared_preferences
├── platform/
│   ├── ntp_channel.dart  gnss_channel.dart  gps_channel.dart
│   ├── power_channel.dart  network_channel.dart
│   └── channel_names.dart
├── providers/                     # Riverpod providers wrapping services
│   ├── server_providers.dart  gps_providers.dart
│   ├── satellite_providers.dart  settings_providers.dart
├── screens/
│   ├── splash/  shell/ (bottom nav)
│   ├── time/  satellite/ (radial_chart, signal_graph, detail)
│   ├── server/ (server_screen, logs, options_sheet)
│   └── about/
├── widgets/                       # shared (gif logo, option sheet, chart)
└── l10n/                          # ARB files for 10 locales

android/app/src/main/kotlin/app/timeserver/
├── MainActivity.kt                # FlutterActivity + channel registration
├── ntp/
│   ├── NtpForegroundService.kt    # FGS: socket loop, wake lock, notification
│   ├── NtpUdpServer.kt            # Kotlin UDP server (design A)
│   ├── NtpPacket.kt               # native codec (or reuse commons-net)
│   ├── PortForwarding.kt          # root iptables (libsuperuser)
│   └── NtpChannel.kt              # MethodChannel + Event stream bridge
├── gnss/GnssStreamHandler.kt      # GnssStatus → EventChannel
├── gps/GpsTimeProvider.kt         # Location.getTime + drift adjust
├── power/PowerChannel.kt          # wakelock + battery optimization intent
└── net/NetworkChannel.kt          # interfaces/IP + connectivity callback

assets/  (pntp_logo.gif, logo_spin_finite.gif, icons)
```

`pubspec.yaml` deps: `flutter_riverpod`, `fl_chart`, `permission_handler`,
`shared_preferences`, `network_info_plus`, `flutter_compass`, `url_launcher`,
`intl`, `mgrs_dart`, `utm`, `open_location_code`, `flutter_localizations`;
optionally `flutter_background_service` (design B).

---

## 8. Platform Channel API Design

Channel name prefix `app.timeserver/`. Methods return Futures; errors as
`PlatformException(code, message)`.

### MethodChannel `…/ntp`  (server control — design A)
| Method | Args | Returns | Errors |
|---|---|---|---|
| `startServer` | `{port:int=1234, stratum:int=1, packetLimit:int?, interface:String?}` | `NtpServerStatus` map | `START_FAILED` (bind/EADDRINUSE), `PERMISSION` |
| `stopServer` | — | `bool` | `NOT_RUNNING` |
| `getStatus` | — | status map `{running, ip, port, interface, stratum, rootRedirected, packetsPerMin}` | — |
| `setStratum` | `{stratum:int}` | `bool` | `RANGE` |
| `setPacketLimit` | `{limit:int}` (0=unlimited) | `bool` | — |
| `setInterface` | `{name:String}` | `NetworkInfo` map | `NO_IFACE` |
| `tryRootRedirect` | — | `{rooted:bool, redirected:bool}` | `NO_ROOT` |

### EventChannel `…/ntp/logs`
Streams minute summaries `{timeReceived:int, inbound:int, outbound:int}` (and/or
per-packet `{ts, isInbound, host, port}`). Backs the packets/min chart.

### EventChannel `…/ntp/status`
Streams `NtpServerStatus` on start/stop, IP/interface change, root-redirect result.

### MethodChannel `…/gps`  +  EventChannel `…/gps/time`
| Method | Args | Returns |
|---|---|---|
| `startLocation` | — | `bool` |
| `stopLocation` | — | `bool` |
| `getGpsTimeMillis` | — | `int` (adjusted) |
| `getOffsetMillis` | — | `int` (|gps−system|) |

Stream payload: `{gpsMillis:int, systemMillis:int, offsetMillis:int, hasFix:bool}`.

### EventChannel `…/gnss/satellites`
Streams `List<SatelliteInfo map>`:
`{svid, constellation:int, constellationName, cn0DbHz:double, azimuth:double,
elevation:double, usedInFix:bool, hasEphemeris:bool, hasAlmanac:bool,
carrierMhz:double?, band:String?}` plus `{inView:int, inUse:int}`.

### MethodChannel `…/power`
`requestIgnoreBatteryOptimizations()→bool`, `isIgnoringBatteryOptimizations()→bool`,
`acquireWakeLock()/releaseWakeLock()` (normally handled inside the FGS).

### MethodChannel `…/network`  +  EventChannel `…/network/changes`
`listInterfaces()→[{name, ipv4, up}]`, `getIpFor(name)→String`; stream emits on
connectivity change.

**Native notes:** start/stop must (a) start/stop the FGS with the right
`foregroundServiceType`, (b) acquire/release the wake lock, (c) (re)bind the
DatagramSocket, (d) optionally call root redirect, (e) push status/logs back via
the Event sinks on the main thread (`runOnUiThread`/`Handler`).

---

## 9. NTP/SNTP Protocol Implementation Notes

**Wire format — 48 bytes (RFC 2030/5905, NTPv3):**
```
byte 0   : LI(2) | VN(3) | Mode(3)         server reply: LI=0, VN=3, Mode=4
byte 1   : Stratum                         1 (primary, GPS) — configurable 1..4
byte 2   : Poll                            0 in this app
byte 3   : Precision (signed)              -20  (≈ 2^-20 s ≈ 0.95 µs, advertised)
byte 4-7 : Root Delay      (16.16 fixed)   62 raw  → ≈0.95 ms
byte 8-11: Root Dispersion (16.16 fixed)   1082 raw → ≈16.5 ms
byte12-15: Reference ID                    'G''P''S''\0' = 0x47505300
byte16-23: Reference Timestamp (64-bit)    = Receive timestamp
byte24-31: Originate Timestamp  (t1)       = client's Transmit timestamp (echoed)
byte32-39: Receive Timestamp    (t2)       = NTP(server receive time)
byte40-47: Transmit Timestamp   (t3)       = NTP(server send time)
```
**Timestamp format:** 64-bit fixed point, seconds since **1900-01-01** in the high
32 bits, fractional seconds in the low 32 bits.
**Epoch conversion:** `ntpSeconds = unixSeconds + 2208988800`. From `millis`:
`intSec = millis/1000 + 2208988800`; `frac = (millis%1000)/1000 * 2^32`.
Reverse: `unixMillis = (ntpHi − 2208988800)*1000 + round(ntpLo/2^32*1000)`.

**Server algorithm (per request):**
1. `receive(48 bytes)` → record `t2 = serverTime()` immediately.
2. Parse byte 0; proceed only if **Mode == 3 (client)**.
3. Build reply: set LI/VN/Mode=0/3/4, stratum, poll, precision, root delay/disp,
   refId 'GPS'.
4. `originate(t1) = client.transmitTimestamp` (copied verbatim — lets the client
   compute round-trip/offset).
5. `receive(t2)`, `reference = t2`.
6. `t3 = serverTime()`; `transmit = NTP(t3)`.
7. `send` to the client's address/port.

**Time source:** `serverTime()` = GPS-disciplined time
(`satelliteMillis + elapsedSinceFix`), fallback system time. Stratum 1 + refId
'GPS' is honest only while a fix exists; when on fallback, consider advertising a
higher stratum or refId 'LOCL' (improvement over the original, which always says
GPS/1).

**Precision/limitations on Android:** `Location.getTime()` and
`System.currentTimeMillis()` are **millisecond**-resolution, and Dart/Java GC +
scheduling add jitter. So although the packet advertises precision −20
(microseconds), realistic accuracy delivered to LAN clients is **~1–30 ms**.
Document this; do not over-promise sub-ms.

**Dart codec correctness:** fix the original's random-byte bug (write the low byte
at `offset+7`, not a fixed index); use `ByteData`/`Uint8List` big-endian; treat
all bytes as unsigned.

---

## 10. UI Recreation Plan (screen-by-screen)

Global theme (from `colors.xml`/`styles.xml`): primary `#a1a1a1`, primaryDark
`#333333`, accent/blue `#67A2C5`, packet incoming `#A17DB7`, outgoing `#7DBB8F`,
white bg; Roboto family; light no-action-bar theme.

**A. Splash** — full-screen `pntp_logo.gif`, ~6 s, then shell. While shown,
request location permission + start location/GNSS. *State:* none. *Native:* start
GPS. *Error:* permission denied → continue, features degrade.

**B. Shell (MainActivity)** — bottom nav, **Time · Satellites · Server · About**
(icons time/satl/serv/info). `autoStart` pref → open Server tab and start server.
*State:* `selectedTab`, `autoStart`.

**C. Time tab** — spinning logo + "PublicNTP"; big time `getAdjustedDateString`
with timezone suffix; offset `±x.xx sec`; latitude/location string; accuracy
`xx m`. Options (⋮) sheet: measurement (Metric/Imperial), time standard
(UTC/Local/Decimal/Swatch), geocoordinate standard (WGS84/UTM/MGRS/OLC), "Open in
Maps", "Copy to clipboard". *State:* `gpsTime`, `offset`, `location`, `accuracy`,
display prefs. *Native:* GPS stream. *Errors:* no fix → `--:--:--.--`, `±--`.

**D. Satellites tab** — counts "in view"/"in use"; **radial sky plot**
(`CustomPaint`: concentric elevation rings, N pointer, triangle=usedInFix /
square=not, grey-shaded by Cn0, SVID labels, optional compass rotation); tap a
satellite → **signal bar chart** (`fl_chart`, sorted by Cn0, grey-shaded) → tap a
bar → **detail** (constellation+SVID, SNR dB-Hz, elevation°, azimuth°, carrier
band). *State:* `List<SatelliteInfo>`, `selectedSvid`, `compassHeading`,
`compassEnabled`. *Native:* GNSS stream + compass plugin. *Errors:* no
satellites → "0 / 0", empty plot.

**E. Server tab** — `SNTP Server` switch; live **packets/min column chart**
(incoming purple / outgoing green, last 60 min); server time + offset; interface/
IP/port line (e.g. `Running on wlan0, 192.168.1.50:1234`). Options (⋮) sheet:
stratum 1–4, network interface, throttle (Unlimited/9000/4800/2400/1200/600),
auto-start switch. *State:* `serverStatus`, `logSummaries`, `stratum`,
`interface`, `packetLimit`, `autoStart`. *Native:* start/stop FGS + status/log
streams. *Errors:* bind fail → toast + switch reverts; no root → "works best with
a rooted device" snackbar; port 123 unavailable note.

**F. About tab** — title, build version, MIT/organization text, credits
(individuals/orgs/projects), delayed "Find out more about PublicNTP / VISIT"
snackbar → opens publicntp.org. *State:* version string.

**Widget tree (shell):**
```
ProviderScope > MaterialApp(localized)
 └ SplashGate → AppShell(Scaffold)
    ├ IndexedStack[ TimeScreen, SatelliteScreen, ServerScreen, AboutScreen ]
    └ BottomNavigationBar(4 items)
ServerScreen
 └ Column[ PacketsBarChart, ServerTimeDisplay, OffsetText, InterfaceIpPort,
           Row[ Switch(server), IconButton(options→ServerOptionsSheet) ] ]
SatelliteScreen
 └ Column[ CountsRow(inView,inUse),
           GestureDetector>CustomPaint(RadialSkyPlot),
           SignalBarChart → SatelliteDetailSheet ]
```

---

## 11. Testing Plan

**Unit (Dart):**
- Epoch conversion round-trips (Unix↔NTP), boundary at 2036 rollover awareness.
- `NtpPacket` encode→decode→encode equals; field bit-packing (LI/VN/Mode,
  stratum, precision sign, 16.16 fixed point).
- Response builder: given a captured client request, assert
  originate==client.transmit, mode==4, refId=='GPS', t2≤t3.
- Log bucketing: synthetic packet stream → correct per-minute inbound/outbound;
  no unbounded growth (the original's leak must not recur).

**Native/integration:**
- Android instrumented test: start FGS, send a client datagram to `:1234` via a
  loopback `RawDatagramSocket`, assert a well-formed 48-byte reply.
- GNSS channel: mock `GnssStatus` → assert SatelliteInfo mapping (Cn0, az, el,
  usedInFix, constellation, carrier band).
- Permission flows: granted / denied / "don't ask again" for location and (API
  33+) notifications.
- No-GPS-fix: assert fallback time path and UI placeholders.
- Foreground-service longevity: run ≥ 8 h with screen off; assert server still
  answers and notification persists; verify wake lock + battery exemption.
- Connectivity change: toggle Wi‑Fi; assert IP/interface refresh in notification
  and Server tab.

**Real NTP-client interop (the acceptance tests):** with phone hotspot or shared
LAN, point clients at `PHONE_IP` (port **1234**, or **123** if rooted+redirected):
- **ESP32** (Arduino/ESP-IDF SNTP): `configTime`/`sntp_setservername(PHONE_IP)`;
  confirm it acquires time; if it hard-codes 123, the phone must be rooted.
- **Linux:** `sntp -d PHONE_IP -p 1234` / `ntpdate -q -u PHONE_IP` /
  `chronyd` with `server PHONE_IP port 1234`.
- **Windows:** `w32tm /stripchart /computer:PHONE_IP /samples:5` (123 only — needs
  root redirect on the phone, or test via a 123-capable build).
- Compare reported offset/round-trip vs a known-good public NTP for sanity
  (expect ~ms-level agreement when the phone has a GPS fix).

---

## 12. Step-by-Step Implementation Roadmap

**Phase 1 — Feature map & scaffolding.** This blueprint; create Flutter project,
folder structure, theme/colors/strings, models, channel-name constants, ARB
localization skeleton (10 locales).

**Phase 2 — UI clone (mock data).** Splash, shell + bottom nav, Time/Satellite/
Server/About screens and option sheets driven by fake Riverpod providers; charts
(`fl_chart`), GIFs, radial `CustomPaint`. Pixel-match labels/colors.

**Phase 3 — Native GPS/GNSS bridge.** Kotlin `GpsTimeProvider` +
`GnssStreamHandler`; `…/gps` and `…/gnss` channels; wire Time + Satellite screens
to real streams; `permission_handler` flows. Acceptance: live sky plot + GPS time.

**Phase 4 — NTP server.** Dart `NtpPacket` codec + tests; Kotlin `NtpUdpServer`
(design A) binding `:1234`; `…/ntp` control + log/status streams; Server tab
fully live; interop-test from Linux `sntp`.

**Phase 5 — Foreground service, wake lock, battery, root.** `NtpForegroundService`
with modern `foregroundServiceType`, persistent notification + "Stop" action,
`PARTIAL_WAKE_LOCK`, battery-optimization prompt; `PortForwarding.kt` root
redirect 123→1234 with graceful no-root fallback; `NetworkChannel` connectivity
refresh. Long-run + background tests.

**Phase 6 — Logs, settings, about, localization.** Packet-rate chart from real
logs; `shared_preferences` for stratum/iface/packets/autoStart/units/timezone/
coords; About + donate snackbar; finalize all 10 locales.

**Phase 7 — Interop & field testing.** ESP32, Linux (`sntp`/`chrony`/`ntpdate`),
Windows (`w32tm`); hotspot + LAN; no-fix and root/non-root matrices.

**Phase 8 — Build & release.** Icons/splash, ProGuard/R8, signed `aab`/`apk`,
Play-policy review for `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` + FGS type
declarations; document the `:1234` vs `:123` client instructions.

---

## 13. Risks & Limitations

1. **Port 123 needs root (hard limit).** Binding privileged ports (<1024) is
   blocked for normal apps; the original works around it with root `iptables`.
   Non-rooted devices: clients must use **`:1234`**. Clients that hard-code 123
   (many ESP32 SNTP defaults, Windows `w32tm`) **cannot** sync to a non-rooted
   phone unless they can override the port. State this prominently in-app.
2. **Background execution restrictions.** A foreground service + wake lock is
   mandatory; even so, aggressive OEM battery managers (Xiaomi/Huawei/Samsung) may
   kill it — hence the battery-optimization exemption prompt. Pure Dart isolates
   alone will not survive backgrounding.
3. **Modern Android targeting (was target 28).** Rebuilding at target 34/35
   requires: declaring `foregroundServiceType` (likely `specialUse` for an NTP
   server, plus `location` if GPS runs in the FGS) and matching
   `FOREGROUND_SERVICE_*` permissions; **runtime `POST_NOTIFICATIONS`** (API 33+);
   `FLAG_IMMUTABLE` PendingIntents (API 31+); background-start FGS limits (start
   the service from a foreground UI action). Google Play scrutinizes both
   `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` and `specialUse` FGS — prepare a
   justification or plan for sideload/enterprise distribution.
4. **GNSS data gaps.** No Flutter plugin exposes full `GnssStatus`; the native
   channel is unavoidable. Many devices report Cn0 but **azimuth/elevation only
   after almanac download**, and **carrier frequency only on API ≥ 27** and
   capable chipsets. Handle missing fields gracefully.
5. **Time accuracy is ~ms, not µs.** `Location.getTime()`/`currentTimeMillis()`
   are millisecond-resolution; advertising precision −20 is optimistic. Realistic
   LAN sync ~1–30 ms. Also: time is only as fresh as the last fix plus elapsed
   system time — under poor sky view the "GPS" time can silently drift to system
   time (the fallback). Consider degrading stratum/refId when on fallback.
6. **Original bugs not to port:** per-packet `RateLimiter` (throttle no-op),
   `setPacketSize` NPE, disabled log cleanup (memory leak), `encodeTimestamp`
   fixed-index random byte, dead manifest receiver. Reimplement correctly.
7. **`commons-net` dependency.** If you keep a Kotlin socket, you can reuse
   `commons-net` `NtpV3Impl` for parity, or use the new Dart `NtpPacket` from
   Kotlin via the engine — simplest is an independent Kotlin/Dart codec.
8. **Coordinate libraries.** Vendored WorldWind/OLC replaced by Dart packages;
   verify MGRS/UTM edge cases (poles, zone boundaries) against the originals.

---

## 14. Final Recommendation

**Proceed with a Flutter UI + thin native core.** Build the entire presentation
layer, NTP packet codec, logging, and coordinate math in Dart (Riverpod state).
Keep a **single Kotlin foreground service** that owns the UDP socket
(design A), the GPS time source, the wake lock, the notification, the battery
exemption, and the optional root redirect; expose it through the Method/Event
channels in §8. Surface the GNSS satellite stream through a dedicated native
`EventChannel`.

This preserves **every original feature** with one unavoidable caveat to
communicate clearly in the UI and docs: **standard NTP port 123 is only available
on rooted devices; otherwise clients connect to port 1234.** Plan the rebuild
against modern Android (FGS types, notification + battery permissions) from day
one. Follow the 8-phase roadmap; gate release on the ESP32/Linux/Windows interop
tests, the long-running background test, and the no-GPS-fix fallback test.

*Recommended first milestone:* Phases 2–4 produce a working, demoable
GPS-time-serving app on `:1234` — the core value — before investing in root,
localization, and store-compliance polish.
