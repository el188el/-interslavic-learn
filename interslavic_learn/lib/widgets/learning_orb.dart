import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Центральная иконка-круг: без радужных переходов и без постоянной анимации (легче для GPU).
class LearningOrb extends StatelessWidget {
  const LearningOrb({
    super.key,
    this.size = 112,
    this.iconSize,
  });

  final double size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final iconSz = iconSize ?? size * 0.36;

    final coreGradient = RadialGradient(
      colors: dark
          ? [
              const Color(0xFFEFF6FF),
              DuoColors.flagBlue,
              DuoColors.flagBlueDeep,
            ]
          : [
              DuoColors.flagWhite,
              DuoColors.flagBlue,
              DuoColors.flagBlueDeep,
            ],
      stops: dark ? const [0.0, 0.55, 1.0] : const [0.0, 0.5, 1.0],
    );

    final glow = DuoColors.flagBlue.withValues(alpha: dark ? 0.32 : 0.22);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size * 1.06,
            height: size * 1.06,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: glow,
                  blurRadius: 28,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
          Container(
            width: size * 0.78,
            height: size * 0.78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: coreGradient,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: dark ? 0.4 : 0.1),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),
          Positioned(
            top: size * 0.18,
            child: Container(
              width: size * 0.35,
              height: size * 0.14,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: dark ? 0.28 : 0.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Icon(
            Icons.school_rounded,
            size: iconSz,
            color: Colors.white.withValues(alpha: 0.96),
            shadows: const [
              Shadow(
                blurRadius: 10,
                color: Colors.black38,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
