import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:interslavic_learn/main.dart' as app;

/// Запуск: `flutter test integration_test` (из каталога `interslavic_learn`).
/// Обычный `flutter test` без пути выполняет только `test/`.
///
/// Веб-таргет (`-d chrome`) для integration_test пока не поддерживается Flutter —
/// тест помечен [skip] на `kIsWeb`. Используйте VM / Windows / Android / iOS.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'приложение стартует и уходит с экрана загрузки',
    (tester) async {
    await app.main();
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);

    for (var i = 0; i < 120; i++) {
      await tester.pump(const Duration(milliseconds: 250));
      if (find.text('Загрузка...').evaluate().isEmpty &&
          find.text('Loading...').evaluate().isEmpty) {
        break;
      }
    }

    expect(find.text('Загрузка...'), findsNothing);
    expect(find.text('Loading...'), findsNothing);

    final welcomeOrHome = find.byWidgetPredicate(
      (w) =>
          w is Text &&
          ((w.data?.contains('Меджуслов') ?? false) ||
              (w.data?.contains('Medžuslov') ?? false) ||
              w.data == 'Курсы' ||
              w.data == 'Courses'),
    );
    expect(welcomeOrHome, findsWidgets);
  },
    skip: kIsWeb,
  );
}
