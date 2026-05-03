import 'package:flutter_test/flutter_test.dart';
import 'package:interslavic_learn/logic/exercise_answer_evaluator.dart';
import 'package:interslavic_learn/models/exercise.dart';

void main() {
  group('isFillBlankAnswerCorrect', () {
    test('accepts Latin answer case-insensitive', () {
      const ex = Exercise(
        type: 'fill_blank',
        instructionRu: '',
        instructionEn: '',
        xp: 10,
        answerIsvLat: 'dobry',
        answerIsvCyr: 'добры',
      );
      expect(isFillBlankAnswerCorrect('  DOBRY ', ex), isTrue);
    });

    test('accepts Cyrillic when both canonical forms set', () {
      const ex = Exercise(
        type: 'fill_blank',
        instructionRu: '',
        instructionEn: '',
        xp: 10,
        answerIsvLat: 'dobry',
        answerIsvCyr: 'добры',
      );
      expect(isFillBlankAnswerCorrect('добры', ex), isTrue);
    });

    test('empty canonical answers require empty user input', () {
      const ex = Exercise(
        type: 'fill_blank',
        instructionRu: '',
        instructionEn: '',
        xp: 10,
      );
      expect(isFillBlankAnswerCorrect('', ex), isTrue);
      expect(isFillBlankAnswerCorrect('x', ex), isFalse);
    });

    test('wrong answer', () {
      const ex = Exercise(
        type: 'fill_blank',
        instructionRu: '',
        instructionEn: '',
        xp: 10,
        answerIsvLat: 'dobry',
      );
      expect(isFillBlankAnswerCorrect('zly', ex), isFalse);
    });
  });

  group('isTextInputAnswerCorrect', () {
    test('matches either script', () {
      const ex = Exercise(
        type: 'text_input',
        instructionRu: '',
        instructionEn: '',
        xp: 10,
        answerIsvLat: 'hello',
        answerIsvCyr: 'хелло',
      );
      expect(isTextInputAnswerCorrect('HELLO', ex), isTrue);
      expect(isTextInputAnswerCorrect('хелло', ex), isTrue);
    });

    test('no match', () {
      const ex = Exercise(
        type: 'text_input',
        instructionRu: '',
        instructionEn: '',
        xp: 10,
        answerIsvLat: 'a',
      );
      expect(isTextInputAnswerCorrect('b', ex), isFalse);
    });
  });

  group('wordMatch helpers', () {
    test('expected translation by locale', () {
      final pair = {'ru': 'дом', 'en': 'house', 'isv_lat': 'dom'};
      expect(wordMatchExpectedTranslation(pair, 'ru'), 'дом');
      expect(wordMatchExpectedTranslation(pair, 'en'), 'house');
    });

    test('left label prefers Cyrillic when requested', () {
      final pair = {'isv_lat': 'dom', 'isv_cyr': 'дом'};
      expect(wordMatchLeftLabel(pair, false), 'dom');
      expect(wordMatchLeftLabel(pair, true), 'дом');
    });
  });
}
