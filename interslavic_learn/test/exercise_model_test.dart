import 'package:flutter_test/flutter_test.dart';
import 'package:interslavic_learn/models/exercise.dart';

void main() {
  test('Exercise.fromJson and accessors', () {
    final ex = Exercise.fromJson({
      'type': 'multiple_choice',
      'instruction_ru': 'Выберите',
      'instruction_en': 'Choose',
      'xp': 15,
      'question_isv_lat': 'dom',
      'question_isv_cyr': 'дом',
      'options_ru': ['дом', 'книга'],
      'options_en': ['house', 'book'],
      'correct_index': 0,
    });
    expect(ex.type, 'multiple_choice');
    expect(ex.xp, 15);
    expect(ex.instruction('ru'), 'Выберите');
    expect(ex.instruction('en'), 'Choose');
    expect(ex.questionIsv(false), 'dom');
    expect(ex.questionIsv(true), 'дом');
    expect(ex.options('ru'), ['дом', 'книга']);
    expect(ex.correctIndex, 0);
  });

  test('fill_blank fields from json', () {
    final ex = Exercise.fromJson({
      'type': 'fill_blank',
      'instruction_ru': 'i',
      'instruction_en': 'i',
      'xp': 10,
      'sentence_isv_lat': '___ jest dom.',
      'answer_isv_lat': 'To',
      'translation_ru': 'Это дом',
    });
    expect(ex.sentenceIsv(false), '___ jest dom.');
    expect(ex.answerIsvLat, 'To');
    expect(ex.translation('ru'), 'Это дом');
  });
}
