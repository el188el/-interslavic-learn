import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interslavic_learn/screens/settings/settings_section_header.dart';

void main() {
  testWidgets('SettingsSectionHeader shows title', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SettingsSectionHeader(title: 'Тема'),
        ),
      ),
    );
    expect(find.text('Тема'), findsOneWidget);
  });
}
