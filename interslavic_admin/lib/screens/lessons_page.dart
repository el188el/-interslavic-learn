import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'lesson_edit_page.dart';

class LessonsPage extends StatefulWidget {
  const LessonsPage({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  final String categoryId;
  final String categoryTitle;

  @override
  State<LessonsPage> createState() => _LessonsPageState();
}

class _LessonsPageState extends State<LessonsPage> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final raw = await Supabase.instance.client
        .from('course_lessons')
        .select('id, category_id, sort_order, payload')
        .eq('category_id', widget.categoryId)
        .order('sort_order', ascending: true);
    final list = raw as List<dynamic>? ?? [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> _reload() async {
    setState(() => _future = _load());
  }

  String _lessonTitle(Map<String, dynamic> row) {
    final p = row['payload'];
    if (p is Map) {
      final m = Map<String, dynamic>.from(p);
      final ru = m['title_ru'] as String?;
      final en = m['title_en'] as String?;
      if (ru != null && ru.isNotEmpty) return ru;
      if (en != null && en.isNotEmpty) return en;
    }
    return row['id'] as String? ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryTitle),
        actions: [
          IconButton(
            tooltip: 'Обновить',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ok = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => LessonEditPage(
                categoryId: widget.categoryId,
              ),
            ),
          );
          if (ok == true && mounted) await _reload();
        },
        icon: const Icon(Icons.add),
        label: const Text('Урок'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('${snap.error}'));
          }
          final rows = snap.data ?? [];
          if (rows.isEmpty) {
            return const Center(child: Text('Пока нет уроков'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final r = rows[i];
              final id = r['id'] as String;
              return ListTile(
                title: Text(_lessonTitle(r)),
                subtitle: Text('id: $id · order ${r['sort_order']}'),
                trailing: const Icon(Icons.edit),
                onTap: () async {
                  final ok = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => LessonEditPage(
                        categoryId: widget.categoryId,
                        initialRow: r,
                      ),
                    ),
                  );
                  if (ok == true && mounted) await _reload();
                },
              );
            },
          );
        },
      ),
    );
  }
}
