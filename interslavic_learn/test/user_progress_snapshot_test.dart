import 'package:flutter_test/flutter_test.dart';
import 'package:interslavic_learn/models/user_progress.dart';

void main() {
  test('snapshotForUi copies fields without sharing mutable lists', () {
    final a = UserProgress(
      displayName: 'Test',
      totalXp: 100,
      completedLessons: ['l1'],
      lessonScores: {'l1': 50},
    );
    final b = a.snapshotForUi();
    expect(identical(a, b), isFalse);
    expect(b.totalXp, 100);
    expect(b.displayName, 'Test');
    b.completedLessons.add('l2');
    expect(a.completedLessons, ['l1']);
  });
}
