import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/enums.dart';
import '../models/gps_time_info.dart';
import '../models/network_interface_info.dart';
import '../models/ntp_server_status.dart';
import '../models/satellite_info.dart';
import '../models/server_log.dart';
import '../platform/compass_platform.dart';
import '../platform/gnss_platform.dart';
import '../platform/gps_platform.dart';
import '../platform/network_platform.dart';
import '../platform/ntp_platform.dart';
import '../platform/power_platform.dart';
import '../services/settings_service.dart';

// --- Platform singletons -----------------------------------------------------

final gpsPlatformProvider = Provider((_) => GpsPlatform());
final gnssPlatformProvider = Provider((_) => GnssPlatform());
final ntpPlatformProvider = Provider((_) => NtpPlatform());
final powerPlatformProvider = Provider((_) => PowerPlatform());
final networkPlatformProvider = Provider((_) => NetworkPlatform());
final compassPlatformProvider = Provider((_) => CompassPlatform());

/// Overridden in main() with the loaded instance.
final sharedPrefsProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('sharedPrefsProvider must be overridden'),
);

final settingsServiceProvider =
    Provider((ref) => SettingsService(ref.watch(sharedPrefsProvider)));

// --- Live data streams -------------------------------------------------------

final gpsTimeProvider = StreamProvider<GpsTimeInfo>(
  (ref) => ref.watch(gpsPlatformProvider).timeStream(),
);

final satellitesProvider = StreamProvider<List<SatelliteInfo>>(
  (ref) => ref.watch(gnssPlatformProvider).satelliteStream(),
);

final compassProvider = StreamProvider<double>(
  (ref) => ref.watch(compassPlatformProvider).headingStream(),
);

final serverLogProvider = StreamProvider<List<ServerLogMinute>>(
  (ref) => ref.watch(ntpPlatformProvider).logStream(),
);

final interfacesProvider = FutureProvider<List<NetworkInterfaceInfo>>(
  (ref) => ref.watch(networkPlatformProvider).listInterfaces(),
);

// --- Settings ----------------------------------------------------------------

final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(settingsServiceProvider).load();

  Future<void> _persist(AppSettings s) async {
    state = s;
    await ref.read(settingsServiceProvider).save(s);
  }

  Future<void> setStratum(int v) => _persist(state.copyWith(stratum: v));
  Future<void> setInterface(String v) => _persist(state.copyWith(interfaceName: v));
  Future<void> setPacketLimit(int v) => _persist(state.copyWith(packetLimit: v));
  Future<void> setAutoStart(bool v) => _persist(state.copyWith(autoStart: v));
  Future<void> setTimeStandard(TimeStandard v) =>
      _persist(state.copyWith(timeStandard: v));
  Future<void> setMeasurement(MeasurementSystem v) =>
      _persist(state.copyWith(measurement: v));
  Future<void> setCoordinateType(CoordinateType v) =>
      _persist(state.copyWith(coordinateType: v));
}

// --- Location lifecycle ------------------------------------------------------

final locationControllerProvider =
    NotifierProvider<LocationController, bool>(LocationController.new);

/// Requests location (+ notification on Android 13+) permission and starts the
/// native GPS/GNSS updates. State = whether location permission is granted.
class LocationController extends Notifier<bool> {
  @override
  bool build() => false;

  Future<bool> ensureStarted() async {
    final status = await Permission.locationWhenInUse.request();
    // Notifications are required to show the foreground-service notification.
    await Permission.notification.request();
    final granted = status.isGranted;
    state = granted;
    if (granted) {
      await ref.read(gpsPlatformProvider).startLocation();
    }
    return granted;
  }
}

// --- NTP server control ------------------------------------------------------

final serverControllerProvider =
    NotifierProvider<ServerController, NtpServerStatus>(ServerController.new);

class ServerController extends Notifier<NtpServerStatus> {
  @override
  NtpServerStatus build() {
    final platform = ref.watch(ntpPlatformProvider);
    final sub = platform.statusStream().listen((s) => state = s);
    ref.onDispose(sub.cancel);
    // Pull initial status (service may already be running, e.g. after restart).
    platform.getStatus().then((s) => state = s).catchError((_) => state);
    return NtpServerStatus.stopped;
  }

  Future<void> start() async {
    final settings = ref.read(settingsControllerProvider);
    final platform = ref.read(ntpPlatformProvider);
    state = await platform.startServer(
      port: NtpServerStatus.stopped.port,
      stratum: settings.stratum,
      packetLimit: settings.packetLimit,
      interfaceName: settings.interfaceName,
    );
  }

  Future<void> stop() async {
    await ref.read(ntpPlatformProvider).stopServer();
    state = NtpServerStatus.stopped;
  }

  Future<void> toggle(bool on) => on ? start() : stop();

  Future<({bool rooted, bool redirected})> tryRoot() =>
      ref.read(ntpPlatformProvider).tryRootRedirect();
}
