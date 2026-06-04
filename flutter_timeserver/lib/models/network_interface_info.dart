/// A usable network interface (eth0/wlan0/usb0/…), ported from
/// `NetworkInterfaceHelper`.
class NetworkInterfaceInfo {
  final String name;
  final String ipv4;
  final bool up;

  const NetworkInterfaceInfo({
    required this.name,
    required this.ipv4,
    required this.up,
  });

  factory NetworkInterfaceInfo.fromMap(Map<dynamic, dynamic> m) => NetworkInterfaceInfo(
        name: (m['name'] as String?) ?? '',
        ipv4: (m['ipv4'] as String?) ?? '0.0.0.0',
        up: (m['up'] as bool?) ?? false,
      );
}
