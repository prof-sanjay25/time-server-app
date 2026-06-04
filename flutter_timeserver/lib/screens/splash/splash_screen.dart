import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_colors.dart';
import '../../providers/providers.dart';
import '../shell/app_shell.dart';

/// Animated splash (PublicNTP GIF). Kicks off location permission + GPS while
/// shown, then transitions to the main shell. Mirrors the original
/// `SplashActivity` (~3.5s here vs the original 6s).
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Start acquiring GPS as early as possible.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationControllerProvider.notifier).ensureStarted();
    });
    _timer = Timer(const Duration(milliseconds: 3500), _goToMain);
  }

  void _goToMain() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AppShell()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Image.asset('assets/images/pntp_logo.gif', fit: BoxFit.contain),
      ),
    );
  }
}
