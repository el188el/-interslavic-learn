import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Загрузка и сохранение `course_categories` / `course_lessons` (как в full_course.json).
class CourseRepository {
  CourseRepository(this._c);

  final SupabaseClient _c;

  static Map<String, dynamic> cloneMap(Map<String, dynamic> m) =>
      Map<String, dynamic>.from(jsonDecode(jsonEncode(m)) as Map);

  Future<bool> currentUserIsAdmin() async {
    final uid = _c.auth.currentUser?.id;
    if (uid == null) return false;
    final row = await _c
        .from('profiles')
        .select('is_admin')
        .eq('id', uid)
        .maybeSingle();
    return row?['is_admin'] == true;
  }

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final rows = await _c
        .from('course_categories')
        .select()
        .order('sort_order', ascending: true);
    return (rows as List<dynamic>).map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      m['order'] = m['sort_order'] ?? 0;
      return m;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchLessons() async {
    final rows = await _c
        .from('course_lessons')
        .select()
        .order('sort_order', ascending: true);
    final out = <Map<String, dynamic>>[];
    for (final raw in rows as List<dynamic>) {
      final row = Map<String, dynamic>.from(raw as Map);
      final payload = row['payload'];
      if (payload is Map<String, dynamic>) {
        out.add(cloneMap(payload));
      } else if (payload is Map) {
        out.add(cloneMap(Map<String, dynamic>.from(payload)));
      }
    }
    return out;
  }

  Future<void> upsertCategory(Map<String, dynamic> cat) async {
    await _c.from('course_categories').upsert({
      'id': cat['id'],
      'sort_order': cat['order'] ?? cat['sort_order'] ?? 0,
      'title_ru': cat['title_ru'],
      'title_en': cat['title_en'],
      'title_isv_lat': cat['title_isv_lat'] ?? '',
      'title_isv_cyr': cat['title_isv_cyr'] ?? '',
      'icon': cat['icon'] ?? 'school',
    });
  }

  Future<void> upsertLesson(Map<String, dynamic> lesson) async {
    final id = lesson['id'] as String;
    final catId = lesson['category_id'] as String;
    final order = (lesson['order'] as num?)?.toInt() ?? 0;
    final payload = cloneMap(lesson);
    await _c.from('course_lessons').upsert({
      'id': id,
      'category_id': catId,
      'sort_order': order,
      'payload': payload,
    });
  }

  Future<void> deleteLesson(String id) async {
    await _c.from('course_lessons').delete().eq('id', id);
  }

  Future<void> deleteCategory(String id) async {
    await _c.from('course_categories').delete().eq('id', id);
  }

  /// Экспорт в том же формате, что `course_import/full_course.json`.
  Map<String, dynamic> buildExportDocument({
    required List<Map<String, dynamic>> categories,
    required List<Map<String, dynamic>> lessons,
  }) {
    return {
      'version': '2.0.0',
      'generated_at': DateTime.now().toUtc().toIso8601String(),
      'note': 'Экспорт из course_editor (Supabase)',
      'categories': categories.map(cloneMap).toList(),
      'lessons': lessons.map(cloneMap).toList(),
    };
  }
}
