import 'dart:convert';
import 'package:flutter/foundation.dart' show ChangeNotifier, debugPrint;
import 'package:flutter/services.dart';
import '../models/category.dart';
import '../models/lesson.dart';
import 'supabase_service.dart';

/// Курсы: при наличии Supabase и данных в `course_*` — с сервера, иначе локальный seed.
class DataService extends ChangeNotifier {
  List<Category> _categories = [];
  List<Lesson> _lessons = [];
  bool _loaded = false;
  bool _fromRemote = false;

  List<Category> get categories => _categories;
  List<Lesson> get lessons => _lessons;
  bool get loadedFromRemote => _fromRemote;

  /// Сначала БД (если настроено), иначе asset `seed_data.json`.
  Future<void> loadAll() async {
    final ok = await tryLoadFromSupabase();
    if (!ok) {
      await loadSeedData();
    }
  }

  Future<bool> tryLoadFromSupabase() async {
    final c = supabaseOrNull;
    if (c == null) return false;
    try {
      final rawCats = await c
          .from('course_categories')
          .select()
          .order('sort_order', ascending: true);
      final list = rawCats as List<dynamic>? ?? [];
      if (list.isEmpty) return false;

      _categories = list
          .map((e) => Category.fromDbRow(Map<String, dynamic>.from(e as Map)))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));

      final rawLessons = await c
          .from('course_lessons')
          .select()
          .order('sort_order', ascending: true);
      final llist = rawLessons as List<dynamic>? ?? [];
      _lessons = llist
          .map((e) => Lesson.fromDbRow(Map<String, dynamic>.from(e as Map)))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));

      _loaded = true;
      _fromRemote = true;
      notifyListeners();
      return true;
    } catch (e, st) {
      debugPrint('tryLoadFromSupabase: $e\n$st');
      return false;
    }
  }

  Future<void> loadSeedData() async {
    if (_fromRemote) return;
    if (_loaded) return;
    final jsonStr = await rootBundle.loadString('assets/data/seed_data.json');
    final data = json.decode(jsonStr) as Map<String, dynamic>;

    _categories = (data['categories'] as List<dynamic>)
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    _lessons = (data['lessons'] as List<dynamic>)
        .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    _loaded = true;
    _fromRemote = false;
    notifyListeners();
  }

  List<Lesson> lessonsForCategory(String categoryId) {
    return _lessons.where((l) => l.categoryId == categoryId).toList();
  }
}
