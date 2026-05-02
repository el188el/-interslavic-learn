import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Создание или правка строки в course_categories.
class CategoryEditPage extends StatefulWidget {
  const CategoryEditPage({super.key, this.initial});

  /// Если null — режим создания новой категории.
  final Map<String, dynamic>? initial;

  @override
  State<CategoryEditPage> createState() => _CategoryEditPageState();
}

class _CategoryEditPageState extends State<CategoryEditPage> {
  late final TextEditingController _id;
  late final TextEditingController _sortOrder;
  late final TextEditingController _titleRu;
  late final TextEditingController _titleEn;
  late final TextEditingController _titleIsvLat;
  late final TextEditingController _titleIsvCyr;
  late final TextEditingController _icon;
  bool _busy = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final r = widget.initial;
    _id = TextEditingController(text: r?['id'] as String? ?? '');
    _sortOrder =
        TextEditingController(text: '${r?['sort_order'] ?? 0}');
    _titleRu = TextEditingController(text: r?['title_ru'] as String? ?? '');
    _titleEn = TextEditingController(text: r?['title_en'] as String? ?? '');
    _titleIsvLat =
        TextEditingController(text: r?['title_isv_lat'] as String? ?? '');
    _titleIsvCyr =
        TextEditingController(text: r?['title_isv_cyr'] as String? ?? '');
    _icon = TextEditingController(text: r?['icon'] as String? ?? 'school');
  }

  @override
  void dispose() {
    _id.dispose();
    _sortOrder.dispose();
    _titleRu.dispose();
    _titleEn.dispose();
    _titleIsvLat.dispose();
    _titleIsvCyr.dispose();
    _icon.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final id = _id.text.trim();
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Укажите id категории (латиница, snake_case)')),
      );
      return;
    }
    final order = int.tryParse(_sortOrder.text.trim()) ?? 0;
    setState(() => _busy = true);
    try {
      await Supabase.instance.client.from('course_categories').upsert({
        'id': id,
        'sort_order': order,
        'title_ru': _titleRu.text.trim(),
        'title_en': _titleEn.text.trim(),
        'title_isv_lat': _titleIsvLat.text.trim(),
        'title_isv_cyr': _titleIsvCyr.text.trim(),
        'icon': _icon.text.trim().isEmpty ? 'school' : _icon.text.trim(),
      });
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить категорию?'),
        content: const Text('Все уроки этой категории будут удалены (CASCADE).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await Supabase.instance.client
          .from('course_categories')
          .delete()
          .eq('id', _id.text.trim());
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Категория' : 'Новая категория'),
        actions: [
          if (_isEdit)
            IconButton(
              tooltip: 'Удалить',
              onPressed: _busy ? null : _delete,
              icon: const Icon(Icons.delete_outline),
            ),
          TextButton(
            onPressed: _busy ? null : _save,
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Сохранить'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _id,
            decoration: const InputDecoration(
              labelText: 'id (ключ)',
              border: OutlineInputBorder(),
              helperText: 'Например cat_travel — после сохранения не меняется проще всего оставить как есть',
            ),
            enabled: !_isEdit,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _sortOrder,
            decoration: const InputDecoration(
              labelText: 'sort_order',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleRu,
            decoration: const InputDecoration(
              labelText: 'title_ru',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleEn,
            decoration: const InputDecoration(
              labelText: 'title_en',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleIsvLat,
            decoration: const InputDecoration(
              labelText: 'title_isv_lat',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleIsvCyr,
            decoration: const InputDecoration(
              labelText: 'title_isv_cyr',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _icon,
            decoration: const InputDecoration(
              labelText: 'icon (Material Icons name)',
              border: OutlineInputBorder(),
              helperText: 'school, restaurant, flight, …',
            ),
          ),
        ],
      ),
    );
  }
}
