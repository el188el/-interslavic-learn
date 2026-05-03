import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Лёгкая микроанимация нажатия (Duolingo-подобная отдача).
class AnimatedBounce extends StatefulWidget {
  const AnimatedBounce({
    super.key,
    required this.child,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<AnimatedBounce> createState() => _AnimatedBounceState();
}

class _AnimatedBounceState extends State<AnimatedBounce> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: 90.ms,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
