class Exercise {
  final String type;
  final String instructionRu;
  final String instructionEn;
  final int xp;

  // word_match
  final List<Map<String, dynamic>>? pairs;

  // multiple_choice
  final String? questionIsvLat;
  final String? questionIsvCyr;
  final List<String>? optionsRu;
  final List<String>? optionsEn;
  final int? correctIndex;

  // fill_blank
  final String? sentenceIsvLat;
  final String? sentenceIsvCyr;
  final String? answerIsvLat;
  final String? answerIsvCyr;
  final String? translationRu;
  final String? translationEn;

  // text_input
  final String? promptRu;
  final String? promptEn;

  // hints
  final String? hintRu;
  final String? hintEn;

  const Exercise({
    required this.type,
    required this.instructionRu,
    required this.instructionEn,
    required this.xp,
    this.pairs,
    this.questionIsvLat,
    this.questionIsvCyr,
    this.optionsRu,
    this.optionsEn,
    this.correctIndex,
    this.sentenceIsvLat,
    this.sentenceIsvCyr,
    this.answerIsvLat,
    this.answerIsvCyr,
    this.translationRu,
    this.translationEn,
    this.promptRu,
    this.promptEn,
    this.hintRu,
    this.hintEn,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      type: json['type'] as String,
      instructionRu: json['instruction_ru'] as String? ?? '',
      instructionEn: json['instruction_en'] as String? ?? '',
      xp: json['xp'] as int? ?? 10,
      pairs: (json['pairs'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      questionIsvLat: json['question_isv_lat'] as String?,
      questionIsvCyr: json['question_isv_cyr'] as String?,
      optionsRu: (json['options_ru'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      optionsEn: (json['options_en'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      correctIndex: json['correct_index'] as int?,
      sentenceIsvLat: json['sentence_isv_lat'] as String?,
      sentenceIsvCyr: json['sentence_isv_cyr'] as String?,
      answerIsvLat: json['answer_isv_lat'] as String?,
      answerIsvCyr: json['answer_isv_cyr'] as String?,
      translationRu: json['translation_ru'] as String?,
      translationEn: json['translation_en'] as String?,
      promptRu: json['prompt_ru'] as String?,
      promptEn: json['prompt_en'] as String?,
      hintRu: json['hint_ru'] as String?,
      hintEn: json['hint_en'] as String?,
    );
  }

  String instruction(String locale) =>
      locale == 'ru' ? instructionRu : instructionEn;

  String? hint(String locale) => locale == 'ru' ? hintRu : hintEn;

  String? questionIsv(bool useCyrillic) =>
      useCyrillic ? questionIsvCyr : questionIsvLat;

  String? sentenceIsv(bool useCyrillic) =>
      useCyrillic ? sentenceIsvCyr : sentenceIsvLat;

  String? answerIsv(bool useCyrillic) =>
      useCyrillic ? answerIsvCyr : answerIsvLat;

  List<String>? options(String locale) =>
      locale == 'ru' ? optionsRu : optionsEn;

  String? prompt(String locale) => locale == 'ru' ? promptRu : promptEn;

  String? translation(String locale) =>
      locale == 'ru' ? translationRu : translationEn;
}
