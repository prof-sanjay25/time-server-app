import 'package:flutter/material.dart';

/// Palette ported 1:1 from the original `res/values/colors.xml`.
class AppColors {
  AppColors._();

  static const Color accent = Color(0xFF67A2C5);
  static const Color primary = Color(0xFFA1A1A1);
  static const Color primaryDark = Color(0xFF333333);
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFFBFBFB);
  static const Color black = Color(0xFF000000);
  static const Color greyDark = Color(0xFF555555);
  static const Color grey = Color(0xFF999999);
  static const Color greyLight = Color(0xFFCCCCCC);
  static const Color blue = Color(0xFF67A2C5);

  /// Incoming packets (purple) / outgoing packets (green) in the server chart.
  static const Color packetIncoming = Color(0xFFA17DB7);
  static const Color packetOutgoing = Color(0xFF7DBB8F);

  static const Color satelliteDetailText = grey;
}
