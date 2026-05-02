// Генерирует канонические PNG для лаунчера и витрины (тот же образ, что логика во InterslavicLanguageIcon).
// Запуск: dart run tool/generate_app_icon_png.dart
import 'dart:io';
import 'dart:math';

import 'package:image/image.dart';

/// Совпадает с lib/widgets/interslavic_language_icon.dart — InterslavicFlagColors
final _blue = ColorRgba8(11, 79, 156, 255);
final _yellow = ColorRgba8(255, 213, 0, 255);
final _red = ColorRgba8(224, 30, 43, 255);
final _white = ColorRgba8(255, 255, 255, 255);

bool _pointInTriangle(
  double px,
  double py,
  double x1,
  double y1,
  double x2,
  double y2,
  double x3,
  double y3,
) {
  double sign(double px0, double py0, double xa, double ya, double xb, double yb) =>
      (px0 - xb) * (ya - yb) - (xa - xb) * (py0 - yb);
  final d1 = sign(px, py, x1, y1, x2, y2);
  final d2 = sign(px, py, x2, y2, x3, y3);
  final d3 = sign(px, py, x3, y3, x1, y1);
  final hasNeg = (d1 < 0) || (d2 < 0) || (d3 < 0);
  final hasPos = (d1 > 0) || (d2 > 0) || (d3 > 0);
  return !(hasNeg && hasPos);
}

bool _inRoundedRect(double x, double y, double w, double h, double radius) {
  final r = min(radius, min(w, h) / 2);
  if (x >= r && x < w - r && y >= 0 && y < h) return true;
  if (y >= r && y < h - r && x >= 0 && x < w) return true;
  if (x < r && y < r) {
    return pow(x - r, 2) + pow(y - r, 2) <= r * r;
  }
  if (x >= w - r && y < r) {
    return pow(x - (w - r), 2) + pow(y - r, 2) <= r * r;
  }
  if (x < r && y >= h - r) {
    return pow(x - r, 2) + pow(y - (h - r), 2) <= r * r;
  }
  if (x >= w - r && y >= h - r) {
    return pow(x - (w - r), 2) + pow(y - (h - r), 2) <= r * r;
  }
  return false;
}

ColorRgba8 _colorAt(double px, double py, double w, double h) {
  final cx = w / 2;
  final cy = h / 2;
  final wm = w - 1;
  final hm = h - 1;
  if (_pointInTriangle(px, py, 0, 0, wm, 0, cx, cy)) return _blue;
  if (_pointInTriangle(px, py, wm, 0, wm, hm, cx, cy)) return _white;
  if (_pointInTriangle(px, py, wm, hm, 0, hm, cx, cy)) return _red;
  if (_pointInTriangle(px, py, 0, hm, 0, 0, cx, cy)) return _yellow;
  return _white;
}

void main() {
  const size = 1024;
  final radius = size * 0.22;

  final flat = Image(width: size, height: size);
  final foreground = Image(width: size, height: size);

  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final fx = x.toDouble();
      final fy = y.toDouble();
      final inShape = _inRoundedRect(fx, fy, size.toDouble(), size.toDouble(), radius);
      if (!inShape) {
        flat.setPixel(x, y, _white);
        foreground.setPixel(x, y, ColorRgba8(0, 0, 0, 0));
      } else {
        final c = _colorAt(fx, fy, size.toDouble(), size.toDouble());
        flat.setPixel(x, y, c);
        foreground.setPixel(x, y, c);
      }
    }
  }

  final dir = Directory('assets/branding');
  if (!dir.existsSync()) dir.createSync(recursive: true);

  final flatPath = 'assets/branding/app_icon.png';
  final fgPath = 'assets/branding/app_icon_foreground.png';

  File(flatPath).writeAsBytesSync(encodePng(flat));
  File(fgPath).writeAsBytesSync(encodePng(foreground));

  // Копия для загрузки на RuStore / консоль (тот же файл, что и для генерации лаунчера).
  File('assets/branding/rustore_listing_icon_512.png').writeAsBytesSync(
    encodePng(copyResize(flat, width: 512, height: 512, interpolation: Interpolation.average)),
  );

  stdout.writeln('Wrote $flatPath, $fgPath, assets/branding/rustore_listing_icon_512.png');
}
