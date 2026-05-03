import 'dart:ui';

import 'package:flutter/material.dart';

/// Стеклянная карточка в духе концепта 2026: blur + полупрозрачность + светлая кромка.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
    this.tint,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final border = dark
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.white.withValues(alpha: 0.95);
    final baseTop = dark
        ? Colors.white.withValues(alpha: 0.09)
        : Colors.white.withValues(alpha: 0.72);
    final top = tint != null
        ? Color.alphaBlend(tint!, baseTop)
        : baseTop;
    final bottom = dark
        ? Colors.white.withValues(alpha: 0.03)
        : Colors.white.withValues(alpha: 0.38);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: border, width: 1),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [top, bottom],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
