import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../course_repository.dart';
import 'lesson_editor_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _repo = CourseRepository(Supabase.instance.client);
  var _loading = true;
  var _allowed = false;
  String? _error;
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _lessons = [];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ok = await _repo.currentUserIsAdmin();
      if (!ok) {
        setState(() {
          _allowed = false;
          _loading = false;
          _error = 'Нет прав администратора (profiles.is_admin).';
        });
        return;
      }
      await _reload();
      setState(() {
        _allowed = true;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _allowed = false;
        _loading = false;
        _error = '$e';
      });
    }
  }

  Future<void> _reload() async {
    _categories = await _repo.fetchCategories();
    _lessons = await _repo.fetchLessons();
    if (mounted) setState(() {});
  }

  Map<String, dynamic> _newLesson(String categoryId) {
    final order = _lessons
        .where((l) => l['category_id'] == categoryId)
        .map((l) => (l['order'] as num?)?.toInt() ?? 0)
        .fold<int>(0, (a, b) => a > b ? a : b);
    return {
      'id': 'lesson_${DateTime.now().millisecondsSinceEpoch}',
      'category_id': categoryId,
      'title_ru': 'Новый урок',
      'title_en': 'New lesson',
      'order': order + 1,
      'theory': {
        'title_ru': '',
        'title_en': '',
        'blocks': <Map<String, dynamic>>[
          {
            'type': 'text',
            'content_ru': '',
            'content_en': '',
          },
        ],
      },
      'exercises': <Map<String, dynamic>>[],
    };
  }

  Future<void> _openLesson(Map<String, dynamic> lesson) async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => LessonEditorPage(
          lesson: lesson,
          categories: _categories,
        ),
      ),
    );
    if (result == null || !mounted) return;
    await _repo.upsertLesson(result);
    await _reload();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Урок сохранён в Supabase')),
      );
    }
  }

  Future<void> _exportJson() async {
    final doc = _repo.buildExportDocument(
      categories: _categories,
      lessons: _lessons,
    );
    final text = const JsonEncoder.withIndent('  ').convert(doc);
    await showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Экспорт JSON'),
        content: SizedBox(
          width: 560,
          height: 420,
          child: SelectionArea(
            child: SingleChildScrollView(
              child: Text(text, style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Закрыть'),
          ),
          FilledButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: text));
              if (c.mounted) Navigator.pop(c);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('JSON скопирован в буфер')),
                );
              }
            },
            child: const Text('Копировать'),
          ),
        ],
      ),
    );
  }

  Future<void> _editCategory(Map<String, dynamic> cat) async {
    final id = cat['id'] as String;
    final ruCtrl = TextEditingController(text: cat['title_ru']?.toString() ?? '');
    final enCtrl = TextEditingController(text: cat['title_en']?.toString() ?? '');
    final latCtrl = TextEditingController(text: cat['title_isv_lat']?.toString() ?? '');
    final cyrCtrl = TextEditingController(text: cat['title_isv_cyr']?.toString() ?? '');
    final iconCtrl = TextEditingController(text: cat['icon']?.toString() ?? 'school');
    final orderCtrl = TextEditingController(text: '${cat['order'] ?? cat['sort_order'] ?? 0}');
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('Категория $id'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: ruCtrl, decoration: const InputDecoration(labelText: 'title_ru')),
                TextField(controller: enCtrl, decoration: const InputDecoration(labelText: 'title_en')),
                TextField(controller: latCtrl, decoration: const InputDecoration(labelText: 'title_isv_lat')),
                TextField(controller: cyrCtrl, decoration: const InputDecoration(labelText: 'title_isv_cyr')),
                TextField(controller: iconCtrl, decoration: const InputDecoration(labelText: 'icon (Material)')),
                TextField(
                  controller: orderCtrl,
                  decoration: const InputDecoration(labelText: 'order'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Отмена')),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Сохранить')),
          ],
        ),
      );
      if (ok != true || !mounted) return;
      await _repo.upsertCategory({
        'id': id,
        'order': int.tryParse(orderCtrl.text) ?? 0,
        'title_ru': ruCtrl.text.trim(),
        'title_en': enCtrl.text.trim(),
        'title_isv_lat': latCtrl.text.trim(),
        'title_isv_cyr': cyrCtrl.text.trim(),
        'icon': iconCtrl.text.trim().isEmpty ? 'school' : iconCtrl.text.trim(),
      });
      await _reload();
    } finally {
      ruCtrl.dispose();
      enCtrl.dispose();
      latCtrl.dispose();
      cyrCtrl.dispose();
      iconCtrl.dispose();
      orderCtrl.dispose();
    }
  }

  Future<void> _addCategory() async {
    final idCtrl = TextEditingController();
    final ruCtrl = TextEditingController();
    final enCtrl = TextEditingController();
    final orderCtrl = TextEditingController(text: '${_categories.length}');
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Новая категория'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: idCtrl, decoration: const InputDecoration(labelText: 'id (лат.)')),
                TextField(controller: ruCtrl, decoration: const InputDecoration(labelText: 'title_ru')),
                TextField(controller: enCtrl, decoration: const InputDecoration(labelText: 'title_en')),
                TextField(
                  controller: orderCtrl,
                  decoration: const InputDecoration(labelText: 'order'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Отмена')),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Создать')),
          ],
        ),
      );
      if (ok != true || !mounted) return;
      final cat = {
        'id': idCtrl.text.trim(),
        'order': int.tryParse(orderCtrl.text) ?? _categories.length,
        'title_ru': ruCtrl.text.trim(),
        'title_en': enCtrl.text.trim(),
        'title_isv_lat': '',
        'title_isv_cyr': '',
        'icon': 'school',
      };
      if (cat['id'] == '') return;
      await _repo.upsertCategory(cat);
      await _reload();
    } finally {
      idCtrl.dispose();
      ruCtrl.dispose();
      enCtrl.dispose();
      orderCtrl.dispose();
    }
  }

  Future<void> _deleteLesson(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Удалить урок?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Нет')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Удалить')),
        ],
      ),
    );
    if (ok == true) {
      await _repo.deleteLesson(id);
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_allowed) {
      return Scaffold(
        appBar: AppBar(title: const Text('Редактор курса')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_error ?? 'Доступ запрещён', textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Курс — редактор'),
        actions: [
          IconButton(
            tooltip: 'Экспорт JSON',
            icon: const Icon(Icons.download_outlined),
            onPressed: _exportJson,
          ),
          IconButton(
            tooltip: 'Обновить',
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
          IconButton(
            tooltip: 'Выйти',
            icon: const Icon(Icons.logout),
            onPressed: () => Supabase.instance.client.auth.signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCategory,
        icon: const Icon(Icons.folder_open),
        label: const Text('Категория'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        itemCount: _categories.length,
        itemBuilder: (context, i) {
          final cat = _categories[i];
          final cid = cat['id'] as String;
          final lessons = _lessons
              .where((l) => l['category_id'] == cid)
              .toList()
            ..sort((a, b) => ((a['order'] as num?)?.toInt() ?? 0)
                .compareTo((b['order'] as num?)?.toInt() ?? 0));
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: Row(
                children: [
                  Expanded(
                    child: Text(cat['title_ru']?.toString() ?? cid),
                  ),
                  IconButton(
                    tooltip: 'Редактировать категорию',
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => _editCategory(cat),
                  ),
                ],
              ),
              subtitle: Text(cid, style: const TextStyle(fontSize: 12)),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.tonalIcon(
                      onPressed: () => _openLesson(_newLesson(cid)),
                      icon: const Icon(Icons.add),
                      label: const Text('Новый урок'),
                    ),
                  ),
                ),
                ...lessons.map((lesson) {
                  final lid = lesson['id'] as String;
                  return ListTile(
                    title: Text(lesson['title_ru']?.toString() ?? lid),
                    subtitle: Text('order ${lesson['order']} · $lid'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _openLesson(lesson),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteLesson(lid),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
