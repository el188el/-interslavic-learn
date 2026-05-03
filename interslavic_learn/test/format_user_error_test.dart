import 'package:flutter_test/flutter_test.dart';
import 'package:interslavic_learn/errors/app_error_codes.dart';

void main() {
  test('formatUserError RU', () {
    final t = formatUserError(
      isRu: true,
      code: 101,
      headlineRu: 'Нет связи',
      headlineEn: 'No connection',
    );
    expect(t, contains('Нет связи'));
    expect(t, contains('101'));
  });

  test('formatUserError EN', () {
    final t = formatUserError(
      isRu: false,
      code: 101,
      headlineRu: 'Нет связи',
      headlineEn: 'No connection',
    );
    expect(t, contains('No connection'));
    expect(t, contains('101'));
  });
}
