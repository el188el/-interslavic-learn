import 'package:flutter_test/flutter_test.dart';
import 'package:interslavic_learn/layout/app_breakpoints.dart';

void main() {
  test('categoryGridColumns by width', () {
    expect(AppBreakpoints.categoryGridColumns(400), 2);
    expect(AppBreakpoints.categoryGridColumns(700), 3);
    expect(AppBreakpoints.categoryGridColumns(1300), 4);
  });

  test('contentMaxWidth caps on large screens', () {
    expect(AppBreakpoints.contentMaxWidth(2000), 1120);
    expect(AppBreakpoints.contentMaxWidth(1000), 960);
    expect(AppBreakpoints.contentMaxWidth(899), 899);
    expect(AppBreakpoints.contentMaxWidth(500), 500);
  });
}
