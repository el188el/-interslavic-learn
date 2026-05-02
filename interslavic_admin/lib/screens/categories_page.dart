import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'category_edit_page.dart';
import 'lessons_page.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final raw = await Supabase.instance.client
        .from('course_categories')
        .select()
        .order('sort_order', ascending: true);
    final list = raw as List<dynamic>? ?? [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> _reload() async {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Категории курса',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Обновить',
                onPressed: _reload,
                icon: const Icon(Icons.refresh),
              ),
              FilledButton.icon(
                onPressed: () async {
                  final ok = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => const CategoryEditPage(),
                    ),
                  );
                  if (ok == true && mounted) await _reload();
                },
                icon: const Icon(Icons.add),
                label: const Text('Категория'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
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
                  return const Center(child: Text('Нет категорий — добавьте или импортируйте сид'));
                }
                return ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final r = rows[i];
                    final id = r['id'] as String;
                    final ru = r['title_ru'] as String? ?? '';
                    final en = r['title_en'] as String? ?? '';
                    return ListTile(
                      title: Text('$ru / $en'),
                      subtitle: Text('id: $id · порядок ${r['sort_order']}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final action = await showModalBottomSheet<String>(
                          context: context,
                          builder: (ctx) => SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.edit),
                                  title: const Text('Изменить категорию'),
                                  onTap: () => Navigator.pop(ctx, 'edit'),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.library_books),
                                  title: const Text('Уроки'),
                                  onTap: () => Navigator.pop(ctx, 'lessons'),
                                ),
                              ],
                            ),
                          ),
                        );
                        if (!mounted) return;
                        if (action == 'edit') {
                          final ok = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              builder: (_) => CategoryEditPage(initial: r),
                            ),
                          );
                          if (ok == true) await _reload();
                        } else if (action == 'lessons') {
                          await Navigator.of(context).push<void>(
                            MaterialPageRoute(
                              builder: (_) => LessonsPage(
                                categoryId: id,
                                categoryTitle: ru.isNotEmpty ? ru : id,
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
