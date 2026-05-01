class Category {
  final String id;
  final String titleRu;
  final String titleEn;
  final String titleIsvLat;
  final String titleIsvCyr;
  final String icon;
  final int order;

  const Category({
    required this.id,
    required this.titleRu,
    required this.titleEn,
    required this.titleIsvLat,
    required this.titleIsvCyr,
    required this.icon,
    required this.order,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      titleRu: json['title_ru'] as String,
      titleEn: json['title_en'] as String,
      titleIsvLat: json['title_isv_lat'] as String? ?? '',
      titleIsvCyr: json['title_isv_cyr'] as String? ?? '',
      icon: json['icon'] as String? ?? 'school',
      order: json['order'] as int? ?? 0,
    );
  }

  String title(String locale) => locale == 'ru' ? titleRu : titleEn;
}
