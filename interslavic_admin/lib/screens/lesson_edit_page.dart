import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Редактор JSON payload урока (как в seed_data.json).
class LessonEditPage extends StatefulWidget {
  const LessonEditPage({
    super.key,
    required this.categoryId,
    this.initialRow,
  });

  final String categoryId;
  final Map<String, dynamic>? initialRow;

  @override
  State<LessonEditPage> createState() => _LessonEditPageState();
}

class _LessonEditPageState extends State<LessonEditPage> {
  late final TextEditingController _id;
  late final TextEditingController _sortOrder;
  late final TextEditingController _json;
  bool _busy = false;

  bool get _isEdit => widget.initialRow != null;

  static String _pretty(Map<String, dynamic> map) {
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  static Map<String, dynamic> _template(String categoryId, String id) {
    return {
      'id': id,
      'category_id': categoryId,
      'title_ru': 'Новый урок',
      'title_en': 'New lesson',
      'order': 0,
      'theory': {
        'title_ru': 'Теория',
        'title_en': 'Theory',
        'blocks': [
          {
            'type': 'paragraph',
            'content_ru': 'Текст на русском.',
            'content_en': 'Text in English.',
          },
        ],
      },
      'exercises': <dynamic>[],
    };
  }

  @override
  void initState() {
    super.initState();
    final row = widget.initialRow;
    if (row != null) {
      final id = row['id'] as String;
      final sort = row['sort_order'];
      final payload = Map<String, dynamic>.from(row['payload'] as Map);
      payload['id'] = id;
      payload['category_id'] = widget.categoryId;
      payload['order'] = sort is int ? sort : int.tryParse('$sort') ?? 0;
      _id = TextEditingController(text: id);
      _sortOrder = TextEditingController(text: '$sort');
      _json = TextEditingController(text: _pretty(payload));
    } else {
      const newId = 'lesson_new';
      final tpl = _template(widget.categoryId, newId);
      _id = TextEditingController(text: newId);
      _sortOrder = TextEditingController(text: '0');
      _json = TextEditingController(text: _pretty(tpl));
    }
  }

  @override
  void dispose() {
    _id.dispose();
    _sortOrder.dispose();
    _json.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final id = _id.text.trim();
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пустой id')),
      );
      return;
    }
    final order = int.tryParse(_sortOrder.text.trim()) ?? 0;
    Map<String, dynamic> payload;
    try {
      payload =
          jsonDecode(_json.text) as Map<String, dynamic>;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Невалидный JSON: $e')),
      );
      return;
    }

    payload['id'] = id;
    payload['category_id'] = widget.categoryId;
    payload['order'] = order;

    setState(() => _busy = true);
    try {
      await Supabase.instance.client.from('course_lessons').upsert({
        'id': id,
        'category_id': widget.categoryId,
        'sort_order': order,
        'payload': payload,
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
        title: const Text('Удалить урок?'),
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
          .from('course_lessons')
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

  Future<void> _copyJson() async {
    await Clipboard.setData(ClipboardData(text: _json.text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('JSON скопирован')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Урок' : 'Новый урок'),
        actions: [
          IconButton(
            tooltip: 'Копировать JSON',
            onPressed: _busy ? null : _copyJson,
            icon: const Icon(Icons.copy),
          ),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _id,
                    decoration: const InputDecoration(
                      labelText: 'id урока',
                      border: OutlineInputBorder(),
                    ),
                    enabled: !_isEdit,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _sortOrder,
                    decoration: const InputDecoration(
                      labelText: 'sort_order',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Тело payload — полный JSON урока (theory, exercises). При сохранении id, category_id и order синхронизируются с полями выше.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: TextField(
                controller: _json,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  alignLabelWithHint: true,
                  labelText: 'JSON',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
