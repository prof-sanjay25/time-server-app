import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_colors.dart';
import '../../l10n/app_localizations.dart';

/// About tab: version, license, content, credits, and a delayed donate
/// snackbar. Ports `AboutFragment`.
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  static const _version = '1.0.30';
  Timer? _snackTimer;

  @override
  void initState() {
    super.initState();
    _snackTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.donateText, style: const TextStyle(color: AppColors.white)),
          action: SnackBarAction(
            label: l.visit,
            textColor: AppColors.blue,
            onPressed: () => launchUrl(Uri.parse('https://publicntp.org'),
                mode: LaunchMode.externalApplication),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _snackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.aboutTitle,
                style: const TextStyle(fontSize: 48, color: AppColors.primaryDark)),
            Text('${l.buildVersion} $_version',
                style: const TextStyle(fontSize: 12, color: AppColors.primary)),
            const SizedBox(height: 8),
            Text(l.aboutOrganization,
                style: const TextStyle(fontSize: 12, color: AppColors.primary)),
            const SizedBox(height: 24),
            Text(l.aboutContent,
                style: const TextStyle(fontSize: 18, color: AppColors.primaryDark)),
            const SizedBox(height: 24),
            Text(l.creditsTitle,
                style: const TextStyle(fontSize: 18, color: AppColors.primaryDark)),
            const SizedBox(height: 8),
            const Text(
              'Individuals: Alex Porter, Alice Neubert, Brad Woodfin, Bryant Oblad, '
              'Cam Peterson, Cody Deskins, Dan Noland, Dane Oborn, Eric Evans, '
              'Keltson Howell, Micah Brown, Richard Macdonald, Scott Waddell, '
              'Terry Ott, Tod Robbins, Wylie Thomas.\n\n'
              'Organizations: Kempt Design LLC, Pony Express Productions, PublicNTP Inc., '
              'Rooster Glue Inc., Sixbucks Solutions.\n\n'
              'Projects: GPSTest Project, Knight Labs, NASA WorldWind, Open Location Code.',
              style: TextStyle(fontSize: 14, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
