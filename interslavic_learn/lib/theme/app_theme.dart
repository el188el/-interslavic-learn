import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Палитра в духе [флага межславянского](https://interslavic.fun): синий · красный · жёлтый · белый.
/// Имена `primaryGreen*` сохранены как алиасы основного акцента (синий), чтобы не ломать импорты.
abstract class DuoColors {
  /// Флаг: верх — королевский синий.
  static const flagBlue = Color(0xFF3B82F6);
  static const flagBlueDeep = Color(0xFF1D4ED8);
  static const flagBlueNight = Color(0xFF1E40AF);
  /// Флаг: низ — красный.
  static const flagRed = Color(0xFFE11D48);
  static const flagRedDeep = Color(0xFFBE123C);
  /// Флаг: слева — жёлтый.
  static const flagYellow = Color(0xFFFACC15);
  static const flagYellowDeep = Color(0xFFEAB308);
  static const flagWhite = Color(0xFFFFFFFF);

  /// Основной акцент интерфейса (аналог прежнего «зелёного» бренда).
  static const primaryGreen = flagBlue;
  static const primaryGreenDeep = flagBlueDeep;
  static const darkGreen = flagBlueNight;

  /// Вторичный акцент — голубее основного (обводки, ссылки).
  static const sky = Color(0xFF60A5FA);
  static const skyDeep = flagBlueDeep;
  /// Третий акцент — раньше лиловый; теперь красный флага для контраста.
  static const lilac = flagRed;
  static const warning = flagYellow;
  static const error = flagRedDeep;
  static const surfaceLight = Color(0xFFF8FAFC);
  static const surfaceLightCard = Color(0xFFFFFFFF);
  static const outlineLight = Color(0xFFE2E8F0);
  static const surfaceDark = Color(0xFF020617);
  static const surfaceDarkCard = Color(0xFF1E293B);
  static const surfaceDarkElevated = Color(0xFF273549);
  static const outlineDark = Color(0xFF475569);
}

ThemeData buildAppLightTheme() {
  final cs = ColorScheme(
    brightness: Brightness.light,
    primary: DuoColors.flagBlueDeep,
    onPrimary: DuoColors.flagWhite,
    primaryContainer: const Color(0xFFDBEAFE),
    onPrimaryContainer: const Color(0xFF1E3A8A),
    secondary: DuoColors.flagRed,
    onSecondary: DuoColors.flagWhite,
    secondaryContainer: const Color(0xFFFFE4E6),
    onSecondaryContainer: const Color(0xFF881337),
    tertiary: DuoColors.flagYellowDeep,
    onTertiary: const Color(0xFF422006),
    tertiaryContainer: const Color(0xFFFEF9C3),
    onTertiaryContainer: const Color(0xFF713F12),
    error: DuoColors.flagRedDeep,
    onError: DuoColors.flagWhite,
    surface: DuoColors.surfaceLight,
    onSurface: const Color(0xFF0F172A),
    onSurfaceVariant: const Color(0xFF475569),
    outline: DuoColors.outlineLight,
    outlineVariant: const Color(0xFFF1F5F4),
    shadow: Colors.black.withValues(alpha: 0.08),
    scrim: Colors.black54,
    inverseSurface: DuoColors.surfaceDarkCard,
    onInverseSurface: DuoColors.surfaceLight,
    inversePrimary: DuoColors.flagBlue,
    surfaceTint: DuoColors.flagBlueDeep.withValues(alpha: 0.12),
    surfaceContainerHighest: const Color(0xFFEEF2F6),
  );

  final base = ThemeData(
    colorScheme: cs,
    useMaterial3: true,
    visualDensity: VisualDensity.standard,
    splashFactory: InkSparkle.splashFactory,
  );

  return base.copyWith(
    scaffoldBackgroundColor: DuoColors.surfaceLight,
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: cs.onSurface,
      displayColor: cs.onSurface,
      fontFamily: GoogleFonts.inter().fontFamily,
    ),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
      iconTheme: IconThemeData(color: cs.onSurface),
      actionsIconTheme: IconThemeData(color: cs.onSurface),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: cs.onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shadowColor: DuoColors.skyDeep.withValues(alpha: 0.14),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: DuoColors.outlineLight.withValues(alpha: 0.65),
          width: 1,
        ),
      ),
      color: DuoColors.surfaceLightCard.withValues(alpha: 0.92),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        elevation: 2,
        shadowColor: DuoColors.darkGreen.withValues(alpha: 0.28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: DuoColors.primaryGreenDeep,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          letterSpacing: 0.2,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        side: BorderSide(color: DuoColors.skyDeep.withValues(alpha: 0.65), width: 2),
        foregroundColor: DuoColors.skyDeep,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 3,
      shadowColor: DuoColors.skyDeep.withValues(alpha: 0.08),
      height: 72,
      backgroundColor: const Color(0xF8FFFFFF),
      surfaceTintColor: Colors.transparent,
      indicatorColor: const Color(0x663B82F6),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith((s) {
        return GoogleFonts.inter(
          fontSize: 12,
          fontWeight: s.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
          letterSpacing: -0.2,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((s) {
        return IconThemeData(
          color: s.contains(WidgetState.selected)
              ? DuoColors.primaryGreenDeep
              : cs.onSurfaceVariant,
          size: 24,
        );
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cs.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: DuoColors.outlineLight.withValues(alpha: 0.8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: DuoColors.primaryGreenDeep, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
  );
}

ThemeData buildAppDarkTheme() {
  final cs = ColorScheme(
    brightness: Brightness.dark,
    primary: DuoColors.flagBlue,
    onPrimary: DuoColors.flagWhite,
    primaryContainer: const Color(0xFF1E3A8A),
    onPrimaryContainer: const Color(0xFFBFDBFE),
    secondary: DuoColors.flagRed,
    onSecondary: DuoColors.flagWhite,
    secondaryContainer: const Color(0xFF881337),
    onSecondaryContainer: const Color(0xFFFFE4E6),
    tertiary: DuoColors.flagYellow,
    onTertiary: const Color(0xFF422006),
    tertiaryContainer: const Color(0xFF713F12),
    onTertiaryContainer: const Color(0xFFFEF9C3),
    error: DuoColors.flagRedDeep,
    onError: DuoColors.flagWhite,
    surface: DuoColors.surfaceDark,
    onSurface: const Color(0xFFF1F5F9),
    onSurfaceVariant: const Color(0xFF94A3B8),
    outline: DuoColors.outlineDark,
    outlineVariant: const Color(0xFF334155),
    shadow: Colors.black.withValues(alpha: 0.45),
    scrim: Colors.black87,
    inverseSurface: DuoColors.surfaceLight,
    onInverseSurface: DuoColors.surfaceDark,
    inversePrimary: DuoColors.flagBlueDeep,
    surfaceTint: DuoColors.flagBlue.withValues(alpha: 0.14),
    surfaceContainerHighest: DuoColors.surfaceDarkElevated,
  );

  final base = ThemeData(
    colorScheme: cs,
    useMaterial3: true,
    visualDensity: VisualDensity.standard,
    splashFactory: InkSparkle.splashFactory,
  );

  return base.copyWith(
    scaffoldBackgroundColor: const Color(0xFF020617),
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: cs.onSurface,
      displayColor: cs.onSurface,
      fontFamily: GoogleFonts.inter().fontFamily,
    ),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      // Совпадает со scaffold — без белой полосы при прозрачном body.
      backgroundColor: const Color(0xFF020617),
      foregroundColor: cs.onSurface,
      iconTheme: IconThemeData(color: cs.onSurface),
      actionsIconTheme: IconThemeData(color: cs.onSurface),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: cs.onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shadowColor: DuoColors.primaryGreen.withValues(alpha: 0.2),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: DuoColors.outlineDark.withValues(alpha: 0.85),
          width: 1,
        ),
      ),
      color: DuoColors.surfaceDarkCard.withValues(alpha: 0.88),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: DuoColors.primaryGreenDeep,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          letterSpacing: 0.2,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        side: BorderSide(color: DuoColors.sky.withValues(alpha: 0.75), width: 2),
        foregroundColor: DuoColors.sky,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.35),
      height: 72,
      backgroundColor: const Color(0xE8182020),
      surfaceTintColor: Colors.transparent,
      indicatorColor: const Color(0x773B82F6),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith((s) {
        return GoogleFonts.inter(
          fontSize: 12,
          fontWeight: s.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
          letterSpacing: -0.2,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((s) {
        return IconThemeData(
          color: s.contains(WidgetState.selected)
              ? DuoColors.primaryGreen
              : cs.onSurfaceVariant,
          size: 24,
        );
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DuoColors.surfaceDarkElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: DuoColors.outlineDark.withValues(alpha: 0.9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: DuoColors.primaryGreen, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
  );
}

/// Совместимость со старыми импортами.
ThemeData buildDuoLightTheme() => buildAppLightTheme();

ThemeData buildDuoDarkTheme() => buildAppDarkTheme();
