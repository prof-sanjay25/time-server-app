import 'package:flutter/services.dart';

import '../models/network_interface_info.dart';
import 'channels.dart';

/// Lists usable interfaces and resolves their IPv4 address, ported from
/// `NetworkInterfaceHelper`, plus a connectivity-change stream.
class NetworkPlatform {
  static const MethodChannel _method = MethodChannel(Channels.networkMethod);
  static const EventChannel _events = EventChannel(Channels.networkEvent);

  Future<List<NetworkInterfaceInfo>> listInterfaces() async {
    final res = await _method.invokeMethod<List<dynamic>>('listInterfaces');
    return (res ?? const [])
        .cast<Map<dynamic, dynamic>>()
        .map(NetworkInterfaceInfo.fromMap)
        .toList();
  }

  Future<String> ipFor(String name) async =>
      (await _method.invokeMethod<String>('ipFor', {'name': name})) ?? '0.0.0.0';

  Stream<void> changes() => _events.receiveBroadcastStream().map((_) {});
}
