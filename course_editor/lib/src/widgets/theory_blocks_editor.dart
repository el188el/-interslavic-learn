import 'package:flutter/material.dart';

/// Редактор `theory.blocks` — типы text, tip, vocabulary_table, grammar_table.
class TheoryBlocksEditor extends StatelessWidget {
  const TheoryBlocksEditor({
    super.key,
    required this.blocks,
    required this.onChanged,
  });

  final List<Map<String, dynamic>> blocks;
  final void Function(List<Map<String, dynamic>>) onChanged;

  void _notify() => onChanged(List<Map<String, dynamic>>.from(blocks));

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'Блоки теории',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            PopupMenuButton<String>(
              tooltip: 'Добавить блок',
              onSelected: (t) {
                blocks.add(_newBlock(t));
                _notify();
              },
              itemBuilder: (c) => const [
                PopupMenuItem(value: 'text', child: Text('Текст')),
                PopupMenuItem(value: 'tip', child: Text('Совет (tip)')),
                PopupMenuItem(
                  value: 'vocabulary_table',
                  child: Text('Таблица слов'),
                ),
                PopupMenuItem(
                  value: 'grammar_table',
                  child: Text('Грамматическая таблица'),
                ),
              ],
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.add),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...blocks.asMap().entries.map((e) {
          final i = e.key;
          final b = e.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Chip(label: Text(b['type']?.toString() ?? '?')),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.arrow_upward),
                        onPressed: i == 0
                            ? null
                            : () {
                                final x = blocks.removeAt(i);
                                blocks.insert(i - 1, x);
                                _notify();
                              },
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_downward),
                        onPressed: i >= blocks.length - 1
                            ? null
                            : () {
                                final x = blocks.removeAt(i);
                                blocks.insert(i + 1, x);
                                _notify();
                              },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          blocks.removeAt(i);
                          _notify();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._fieldsForBlock(context, b, () => _notify()),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Map<String, dynamic> _newBlock(String type) {
    switch (type) {
      case 'tip':
      case 'text':
        return {
          'type': type,
          'content_ru': '',
          'content_en': '',
        };
      case 'vocabulary_table':
        return {
          'type': 'vocabulary_table',
          'items': <Map<String, dynamic>>[
            {'isv_lat': '', 'isv_cyr': '', 'ru': '', 'en': ''},
          ],
        };
      case 'grammar_table':
        return {
          'type': 'grammar_table',
          'rows': <List<String>>[
            ['Заголовок 1', 'Заголовок 2'],
            ['', ''],
          ],
        };
      default:
        return {'type': 'text', 'content_ru': '', 'content_en': ''};
    }
  }

  List<Widget> _fieldsForBlock(
    BuildContext context,
    Map<String, dynamic> b,
    VoidCallback save,
  ) {
    final t = b['type']?.toString() ?? 'text';
    switch (t) {
      case 'text':
      case 'tip':
        return [
          TextFormField(
            initialValue: b['content_ru']?.toString() ?? '',
            decoration: const InputDecoration(
              labelText: 'Текст (RU)',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            onChanged: (v) {
              b['content_ru'] = v;
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: b['content_en']?.toString() ?? '',
            decoration: const InputDecoration(
              labelText: 'Text (EN)',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            onChanged: (v) {
              b['content_en'] = v;
            },
          ),
        ];
      case 'vocabulary_table':
        final items = (b['items'] as List<dynamic>?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            <Map<String, dynamic>>[];
        b['items'] = items;
        return [
          ...items.asMap().entries.map((e) {
            final j = e.key;
            final row = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: row['isv_lat']?.toString() ?? '',
                      decoration: const InputDecoration(
                        labelText: 'ISV lat',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => row['isv_lat'] = v,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextFormField(
                      initialValue: row['isv_cyr']?.toString() ?? '',
                      decoration: const InputDecoration(
                        labelText: 'ISV kir',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => row['isv_cyr'] = v,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextFormField(
                      initialValue: row['ru']?.toString() ?? '',
                      decoration: const InputDecoration(
                        labelText: 'RU',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => row['ru'] = v,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextFormField(
                      initialValue: row['en']?.toString() ?? '',
                      decoration: const InputDecoration(
                        labelText: 'EN',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => row['en'] = v,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      items.removeAt(j);
                      save();
                    },
                  ),
                ],
              ),
            );
          }),
          TextButton.icon(
            onPressed: () {
              items.add({
                'isv_lat': '',
                'isv_cyr': '',
                'ru': '',
                'en': '',
              });
              save();
            },
            icon: const Icon(Icons.add),
            label: const Text('Строка'),
          ),
        ];
      case 'grammar_table':
        final rows = (b['rows'] as List<dynamic>?)
                ?.map((r) => (r as List<dynamic>).map((c) => c.toString()).toList())
                .toList() ??
            <List<String>>[
              ['', ''],
            ];
        b['rows'] = rows;
        return [
          const Text(
            'Первая строка — заголовки. «Колонка» добавляет ячейку в каждую строку.',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  for (final r in rows) {
                    r.add('');
                  }
                  save();
                },
                icon: const Icon(Icons.view_column_outlined),
                label: const Text('Колонка'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  final n = rows.isEmpty ? 2 : rows.first.length;
                  rows.add(List<String>.filled(n, ''));
                  save();
                },
                icon: const Icon(Icons.add),
                label: const Text('Строка'),
              ),
              OutlinedButton.icon(
                onPressed: rows.isEmpty || rows.first.length <= 1
                    ? null
                    : () {
                        for (final r in rows) {
                          if (r.isNotEmpty) r.removeLast();
                        }
                        save();
                      },
                icon: const Icon(Icons.remove),
                label: const Text('Убрать колонку'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...rows.asMap().entries.map((e) {
            final ri = e.key;
            final cells = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...cells.asMap().entries.map((ce) {
                    final ci = ce.key;
                    final val = ce.value;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: TextFormField(
                          key: ValueKey('g_${ri}_$ci'),
                          initialValue: val,
                          decoration: InputDecoration(
                            labelText: 'r$ri c$ci',
                            isDense: true,
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (v) {
                            cells[ci] = v;
                          },
                        ),
                      ),
                    );
                  }),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      rows.removeAt(ri);
                      save();
                    },
                  ),
                ],
              ),
            );
          }),
        ];
      default:
        return [
          Text('Неизвестный тип: $t', style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ];
    }
  }
}
