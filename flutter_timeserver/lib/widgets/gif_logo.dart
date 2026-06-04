import 'package:flutter/material.dart';

/// Animated PublicNTP logo (Flutter decodes GIFs natively via [Image.asset]).
class GifLogo extends StatelessWidget {
  final double size;
  final String asset;
  const GifLogo({super.key, this.size = 70, this.asset = 'assets/images/logo_spin_finite.gif'});

  @override
  Widget build(BuildContext context) {
    return Image.asset(asset, width: size, height: size, gaplessPlayback: true);
  }
}
