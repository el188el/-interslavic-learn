import 'package:flutter_test/flutter_test.dart';
import 'package:interslavic_learn/models/lesson_checkpoint.dart';

void main() {
  test('roundtrip encode / decode', () {
    const c = LessonCheckpoint(
      resumeExerciseIndex: 3,
      xpGrantedExerciseIndices: [0, 1, 2],
    );
    final raw = c.encode();
    final back = LessonCheckpoint.decode(raw);
    expect(back, isNotNull);
    expect(back!.resumeExerciseIndex, 3);
    expect(back.xpGrantedExerciseIndices, [0, 1, 2]);
  });

  test('decode null or empty returns null', () {
    expect(LessonCheckpoint.decode(null), isNull);
    expect(LessonCheckpoint.decode(''), isNull);
  });

  test('decode invalid json returns null', () {
    expect(LessonCheckpoint.decode('not-json'), isNull);
  });
}
