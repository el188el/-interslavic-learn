import 'exercise.dart';

class TheoryBlock {
  final String type;
  final String? contentRu;
  final String? contentEn;
  final List<Map<String, dynamic>>? items;
  final List<List<String>>? rows;

  const TheoryBlock({
    required this.type,
    this.contentRu,
    this.contentEn,
    this.items,
    this.rows,
  });

  factory TheoryBlock.fromJson(Map<String, dynamic> json) {
    return TheoryBlock(
      type: json['type'] as String,
      contentRu: json['content_ru'] as String?,
      contentEn: json['content_en'] as String?,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      rows: (json['rows'] as List<dynamic>?)
          ?.map((e) => (e as List<dynamic>).map((c) => c.toString()).toList())
          .toList(),
    );
  }

  String? content(String locale) =>
      locale == 'ru' ? contentRu : contentEn;
}

class Theory {
  final String titleRu;
  final String titleEn;
  final List<TheoryBlock> blocks;

  const Theory({
    required this.titleRu,
    required this.titleEn,
    required this.blocks,
  });

  factory Theory.fromJson(Map<String, dynamic> json) {
    return Theory(
      titleRu: json['title_ru'] as String? ?? '',
      titleEn: json['title_en'] as String? ?? '',
      blocks: (json['blocks'] as List<dynamic>?)
              ?.map((e) => TheoryBlock.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  String title(String locale) => locale == 'ru' ? titleRu : titleEn;
}

class Lesson {
  final String id;
  final String categoryId;
  final String titleRu;
  final String titleEn;
  final int order;
  final Theory theory;
  final List<Exercise> exercises;

  const Lesson({
    required this.id,
    required this.categoryId,
    required this.titleRu,
    required this.titleEn,
    required this.order,
    required this.theory,
    required this.exercises,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      titleRu: json['title_ru'] as String,
      titleEn: json['title_en'] as String,
      order: json['order'] as int? ?? 0,
      theory: Theory.fromJson(json['theory'] as Map<String, dynamic>),
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => Exercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  String title(String locale) => locale == 'ru' ? titleRu : titleEn;
}
