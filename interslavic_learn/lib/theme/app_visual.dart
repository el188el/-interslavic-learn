import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Фон и тени в духе палитры флага (без «радужных» градиентов).
abstract final class AppVisual {
  static LinearGradient chromeLinearGradient(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    if (dark) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF020617),
          Color(0xFF0F172A),
        ],
      );
    }
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        DuoColors.surfaceLight,
        Color(0xFFE8EEF5),
      ],
    );
  }

  @Deprecated('Use chromeLinearGradient')
  static LinearGradient scaffoldGradient(BuildContext context) =>
      chromeLinearGradient(context);

  static List<BoxShadow> cardShadowLight(BuildContext context) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 10),
          spreadRadius: -4,
        ),
        BoxShadow(
          color: DuoColors.flagBlueDeep.withValues(alpha: 0.14),
          blurRadius: 24,
          offset: const Offset(0, 14),
          spreadRadius: -6,
        ),
      ];

  static List<BoxShadow> cardShadowDark(BuildContext context) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.45),
          blurRadius: 24,
          offset: const Offset(0, 12),
          spreadRadius: -6,
        ),
        BoxShadow(
          color: DuoColors.flagBlue.withValues(alpha: 0.2),
          blurRadius: 28,
          offset: const Offset(0, 14),
          spreadRadius: -8,
        ),
      ];

  static List<BoxShadow> primaryButtonShadow(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: (dark ? DuoColors.flagBlue : DuoColors.flagBlueNight)
            .withValues(alpha: dark ? 0.42 : 0.35),
        blurRadius: dark ? 22 : 18,
        offset: const Offset(0, 8),
        spreadRadius: -2,
      ),
    ];
  }

  /// Два оттенка синего флага (основная CTA).
  static LinearGradient primaryCtaGradient(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: dark
          ? const [
              DuoColors.flagBlue,
              DuoColors.flagBlueDeep,
            ]
          : const [
              DuoColors.flagBlueDeep,
              DuoColors.flagBlueNight,
            ],
    );
  }

  @Deprecated('Use Theme.colorScheme.primary for titles')
  static LinearGradient headlineGradient(BuildContext context) {
    final c = Theme.of(context).colorScheme.primary;
    return LinearGradient(colors: [c, c]);
  }
}
