import 'package:flutter/material.dart';

import '../theme/app_visual.dart';

/// Полноэкранный фон: лёгкий вертикальный градиент без цветных «орбов» (быстрее на GPU).
class AppChromeBackground extends StatelessWidget {
  const AppChromeBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppVisual.chromeLinearGradient(context),
          ),
        ),
        child,
      ],
    );
  }
}
