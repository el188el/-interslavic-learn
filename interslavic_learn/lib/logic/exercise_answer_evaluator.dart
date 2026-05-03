import '../models/exercise.dart';

/// Проверка ответа для типа `fill_blank` (как в [FillBlankExercise]).
bool isFillBlankAnswerCorrect(String rawInput, Exercise exercise) {
  final input = rawInput.trim().toLowerCase();
  final correctLat = (exercise.answerIsvLat ?? '').trim().toLowerCase();
  final correctCyr = (exercise.answerIsvCyr ?? '').trim().toLowerCase();
  final bothEmpty = correctLat.isEmpty && correctCyr.isEmpty;
  if (bothEmpty) return input.isEmpty;
  return input == correctLat || input == correctCyr;
}

/// Проверка ответа для типа `text_input` (как в [TextInputExercise]).
bool isTextInputAnswerCorrect(String rawInput, Exercise exercise) {
  final input = rawInput.trim().toLowerCase();
  final correctLat = (exercise.answerIsvLat ?? '').trim().toLowerCase();
  final correctCyr = (exercise.answerIsvCyr ?? '').trim().toLowerCase();
  return input == correctLat || input == correctCyr;
}

/// Ожидаемый перевод для пары в `word_match` (правая колонка).
String wordMatchExpectedTranslation(
  Map<String, dynamic> pair,
  String locale,
) {
  return (locale == 'ru' ? pair['ru'] : pair['en']) as String? ?? '';
}

/// Левая подпись ISV в зависимости от письменности.
String wordMatchLeftLabel(Map<String, dynamic> pair, bool useCyrillic) {
  if (useCyrillic) {
    return (pair['isv_cyr'] ?? pair['isv_lat'] ?? '') as String;
  }
  return (pair['isv_lat'] ?? '') as String;
}
