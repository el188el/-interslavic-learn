import 'package:flutter_test/flutter_test.dart';
import 'package:interslavic_learn/models/lesson.dart';

void main() {
  test('Lesson.fromJson minimal', () {
    final lesson = Lesson.fromJson({
      'id': 'l1',
      'category_id': 'cat',
      'title_ru': 'Урок',
      'title_en': 'Lesson',
      'order': 2,
      'theory': {
        'title_ru': 'Т',
        'title_en': 'T',
        'blocks': [],
      },
      'exercises': [
        {
          'type': 'multiple_choice',
          'instruction_ru': 'i',
          'instruction_en': 'i',
          'xp': 5,
          'correct_index': 0,
        },
      ],
    });
    expect(lesson.id, 'l1');
    expect(lesson.categoryId, 'cat');
    expect(lesson.title('en'), 'Lesson');
    expect(lesson.exercises.length, 1);
    expect(lesson.exercises.first.type, 'multiple_choice');
  });
}
