import 'package:flutter/cupertino.dart';

class AppTheme {
  // Animation Durations - matching iOS standards
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 400);

  // Colors
  static const Color primaryBlue = CupertinoColors.systemBlue;
  static const Color accentCoral = CupertinoColors.systemOrange;
  static const Color backgroundLight = CupertinoColors.systemBackground;
  static const Color surfaceLight = CupertinoColors.secondarySystemBackground;
  static const Color textPrimary = CupertinoColors.label;
  static const Color textSecondary = CupertinoColors.secondaryLabel;

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border Radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;

  // Shadows
  static List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: CupertinoColors.black.withOpacity(0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: CupertinoColors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  // Text Styles
  static TextStyle get headingLarge => const TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.41,
    color: textPrimary,
  );

  static TextStyle get headingMedium => const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.34,
    color: textPrimary,
  );

  static TextStyle get bodyLarge => const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.41,
    color: textPrimary,
  );

  static TextStyle get bodyMedium => const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.24,
    color: textPrimary,
  );

  static TextStyle get buttonText => const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
    color: CupertinoColors.white,
  );

  // Theme Data
  static CupertinoThemeData get theme => const CupertinoThemeData(
    brightness: Brightness.light,
    primaryColor: primaryBlue,
    primaryContrastingColor: CupertinoColors.white,
    scaffoldBackgroundColor: backgroundLight,
    barBackgroundColor: surfaceLight,
    textTheme: CupertinoTextThemeData(
      primaryColor: primaryBlue,
      textStyle: TextStyle(
        fontSize: 17,
        color: textPrimary,
        letterSpacing: -0.41,
      ),
      actionTextStyle: TextStyle(
        fontSize: 17,
        color: primaryBlue,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.41,
      ),
      navTitleTextStyle: TextStyle(
        fontSize: 17,
        color: textPrimary,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.41,
      ),
      navLargeTitleTextStyle: TextStyle(
        fontSize: 34,
        color: textPrimary,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.41,
      ),
      navActionTextStyle: TextStyle(
        fontSize: 17,
        color: primaryBlue,
        letterSpacing: -0.41,
      ),
      pickerTextStyle: TextStyle(
        fontSize: 21,
        color: textPrimary,
        letterSpacing: -0.41,
      ),
      dateTimePickerTextStyle: TextStyle(
        fontSize: 21,
        color: textPrimary,
        letterSpacing: -0.41,
      ),
      tabLabelTextStyle: TextStyle(
        fontSize: 10,
        color: textPrimary,
        letterSpacing: -0.24,
      ),
    ),
  );
} 