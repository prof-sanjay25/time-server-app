import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../about/about_screen.dart';
import '../satellite/satellite_screen.dart';
import '../server/server_screen.dart';
import '../time/time_screen.dart';

/// Main shell: bottom navigation over Time · Satellites · Server · About,
/// matching the original `MainActivity` tab order.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  static const _screens = [
    TimeScreen(),
    SatelliteScreen(),
    ServerScreen(),
    AboutScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure GPS is running (splash may have been skipped on hot reload).
      ref.read(locationControllerProvider.notifier).ensureStarted();
      // Honor auto-start: jump to Server tab and start the service.
      final settings = ref.read(settingsControllerProvider);
      if (settings.autoStart) {
        setState(() => _index = 2);
        ref.read(serverControllerProvider.notifier).start();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.blue,
        unselectedItemColor: AppColors.greyDark,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.access_time), label: l.tabTime),
          BottomNavigationBarItem(icon: const Icon(Icons.satellite_alt), label: l.tabSatellites),
          BottomNavigationBarItem(icon: const Icon(Icons.dns), label: l.tabServer),
          BottomNavigationBarItem(icon: const Icon(Icons.info_outline), label: l.tabAbout),
        ],
      ),
    );
  }
}
