import 'package:flutter_test/flutter_test.dart';
import 'package:interslavic_learn/models/lesson.dart';

void main() {
  test('TheoryBlock.fromJson and content()', () {
    final b = TheoryBlock.fromJson({
      'type': 'paragraph',
      'content_ru': 'Текст',
      'content_en': 'Text',
    });
    expect(b.type, 'paragraph');
    expect(b.content('ru'), 'Текст');
    expect(b.content('en'), 'Text');
  });
}
