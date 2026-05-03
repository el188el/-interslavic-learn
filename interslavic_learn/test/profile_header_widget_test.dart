import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interslavic_learn/models/user_progress.dart';
import 'package:interslavic_learn/screens/profile/profile_header.dart';

void main() {
  testWidgets('ProfileHeader shows display name', (tester) async {
    final p = UserProgress(displayName: 'Medžuslovjanin');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileHeader(progress: p),
        ),
      ),
    );
    expect(find.text('Medžuslovjanin'), findsOneWidget);
  });
}
