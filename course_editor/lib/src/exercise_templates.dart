/// Пустые шаблоны упражнений (поля как в приложении / JSON курса).
Map<String, dynamic> templateExercise(String type) {
  switch (type) {
    case 'word_match':
      return {
        'type': 'word_match',
        'instruction_ru': 'Соедините пары',
        'instruction_en': 'Match the pairs',
        'pairs': <Map<String, dynamic>>[
          {
            'isv_lat': '',
            'isv_cyr': '',
            'ru': '',
            'en': '',
          },
        ],
        'xp': 12,
        'hint_ru': '',
        'hint_en': '',
      };
    case 'multiple_choice':
      return {
        'type': 'multiple_choice',
        'instruction_ru': 'Выберите верный ответ',
        'instruction_en': 'Choose the correct answer',
        'question_isv_lat': '',
        'question_isv_cyr': '',
        'options_ru': ['', '', '', ''],
        'options_en': ['', '', '', ''],
        'correct_index': 0,
        'xp': 12,
        'hint_ru': '',
        'hint_en': '',
      };
    case 'fill_blank':
      return {
        'type': 'fill_blank',
        'instruction_ru': 'Вставьте пропуск',
        'instruction_en': 'Fill the gap',
        'sentence_isv_lat': '___',
        'sentence_isv_cyr': '___',
        'answer_isv_lat': '',
        'answer_isv_cyr': '',
        'translation_ru': '',
        'translation_en': '',
        'xp': 12,
        'hint_ru': '',
        'hint_en': '',
      };
    case 'text_input':
      return {
        'type': 'text_input',
        'instruction_ru': 'Введите ответ',
        'instruction_en': 'Type the answer',
        'prompt_ru': '',
        'prompt_en': '',
        'answer_isv_lat': '',
        'answer_isv_cyr': '',
        'xp': 12,
        'hint_ru': '',
        'hint_en': '',
      };
    default:
      return templateExercise('word_match');
  }
}

const kExerciseTypes = [
  'word_match',
  'multiple_choice',
  'fill_blank',
  'text_input',
];
