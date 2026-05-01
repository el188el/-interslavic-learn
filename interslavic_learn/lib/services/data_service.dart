import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/category.dart';
import '../models/lesson.dart';

class DataService {
  List<Category> _categories = [];
  List<Lesson> _lessons = [];
  bool _loaded = false;

  List<Category> get categories => _categories;
  List<Lesson> get lessons => _lessons;

  Future<void> loadSeedData() async {
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
  }

  List<Lesson> lessonsForCategory(String categoryId) {
    return _lessons.where((l) => l.categoryId == categoryId).toList();
  }
}
