import 'package:flutter_test/flutter_test.dart';
import 'package:interslavic_learn/models/user_progress.dart';

void main() {
  test('snapshotForUi копирует поля без общей ссылки на коллекции', () {
    final a = UserProgress(
      totalXp: 42,
      completedLessons: ['l1'],
      lessonScores: {'l1': 10},
      lessonCheckpoints: {},
      displayName: 'Test',
    );
    final b = a.snapshotForUi();

    expect(identical(a, b), isFalse);
    expect(b.totalXp, 42);
    expect(b.completedLessons, ['l1']);
    expect(identical(a.completedLessons, b.completedLessons), isFalse);
    expect(b.lessonScores['l1'], 10);
    expect(identical(a.lessonScores, b.lessonScores), isFalse);
  });
}
