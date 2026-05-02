import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Брейкпоинты для телефона / планшета / окна на ПК и веба.
abstract final class AppBreakpoints {
  static const double compact = 600;
  static const double medium = 900;
  static const double expanded = 1200;

  /// Ограничивает ширину контента на больших мониторах (центрирование).
  static double contentMaxWidth(double windowWidth) {
    if (windowWidth >= expanded) return 1120;
    if (windowWidth >= medium) return 960;
    return windowWidth;
  }

  static int categoryGridColumns(double width) {
    if (width >= expanded) return 4;
    if (width >= compact) return 3;
    return 2;
  }

  /// Горизонтальные плитки: width / height. Чем выше число, тем ниже ячейка (компактнее под баннер).
  static double categoryGridAspectRatio(double width) {
    if (width >= expanded) return 2.12;
    if (width >= medium) return 1.98;
    return 1.82;
  }

  static EdgeInsets contentPadding(double width) {
    final h = width >= medium ? 28.0 : 18.0;
    final v = width >= medium ? 24.0 : 20.0;
    return EdgeInsets.fromLTRB(h, v, h, v);
  }

  static double gridSpacing(double width) =>
      width >= medium ? 16.0 : 14.0;

  static bool isComfortableWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= medium;

  /// Размер иконки в карточке категории (меньше на широких макетах — смотрится аккуратнее).
  static double categoryIconSize(double width) {
    if (width >= expanded) return 30;
    if (width >= medium) return 32;
    return 36;
  }

  /// Заголовок AppBar: на очень широких экранах чуть компактнее визуально.
  static double appBarTitleFontSize(double width) {
    if (width >= expanded) return 18;
    if (width >= medium) return 19;
    return 20;
  }

  /// Эффективная ширина колонки контента (не растягиваем на весь 4K-монитор).
  static double bodyWidth(double windowWidth) =>
      math.min(windowWidth, contentMaxWidth(windowWidth));
}
