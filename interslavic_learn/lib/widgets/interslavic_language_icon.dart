import 'package:flutter/material.dart';

/// Палитра флага межславянского языка (четыре сектора от центра).
abstract final class InterslavicFlagColors {
  static const blue = Color(0xFF0B4F9C);
  static const yellow = Color(0xFFFFD500);
  static const red = Color(0xFFE01E2B);
  static const white = Color(0xFFFFFFFF);
}

/// Миниатюра флага: верх — синий, низ — красный, слева — жёлтый, справа — белый;
/// границы — диагонали угла–к–углу, пересечение в центре.
class InterslavicLanguageIcon extends StatelessWidget {
  const InterslavicLanguageIcon({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final outline = brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.25)
        : Colors.black.withValues(alpha: 0.12);

    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.22),
          border: Border.all(color: outline, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.18),
          child: CustomPaint(
            size: Size(size, size),
            painter: const _InterslavicQuarteredFlagPainter(),
          ),
        ),
      ),
    );
  }
}

class _InterslavicQuarteredFlagPainter extends CustomPainter {
  const _InterslavicQuarteredFlagPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    // Верх: (0,0) — (w,0) — центр
    final top = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(cx, cy)
      ..close();

    // Справа: (w,0) — (w,h) — центр
    final right = Path()
      ..moveTo(w, 0)
      ..lineTo(w, h)
      ..lineTo(cx, cy)
      ..close();

    // Низ: (w,h) — (0,h) — центр
    final bottom = Path()
      ..moveTo(w, h)
      ..lineTo(0, h)
      ..lineTo(cx, cy)
      ..close();

    // Слева: (0,h) — (0,0) — центр
    final left = Path()
      ..moveTo(0, h)
      ..lineTo(0, 0)
      ..lineTo(cx, cy)
      ..close();

    final paint = Paint()..style = PaintingStyle.fill;

    canvas.drawPath(top, paint..color = InterslavicFlagColors.blue);
    canvas.drawPath(right, paint..color = InterslavicFlagColors.white);
    canvas.drawPath(bottom, paint..color = InterslavicFlagColors.red);
    canvas.drawPath(left, paint..color = InterslavicFlagColors.yellow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
