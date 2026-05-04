import 'package:flutter/material.dart';

import '../exercise_templates.dart';

/// Редактор одного элемента `exercises[]`.
class ExerciseCardEditor extends StatefulWidget {
  const ExerciseCardEditor({
    super.key,
    required this.exercise,
    required this.onChangedType,
    required this.onRemove,
  });

  final Map<String, dynamic> exercise;
  final void Function(String newType) onChangedType;
  final VoidCallback onRemove;

  @override
  State<ExerciseCardEditor> createState() => _ExerciseCardEditorState();
}

class _ExerciseCardEditorState extends State<ExerciseCardEditor> {
  Map<String, dynamic> get e => widget.exercise;

  @override
  Widget build(BuildContext context) {
    final type = e['type']?.toString() ?? 'word_match';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                DropdownButton<String>(
                  value: kExerciseTypes.contains(type) ? type : 'word_match',
                  items: kExerciseTypes
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(t),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v == null || v == type) return;
                    widget.onChangedType(v);
                  },
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: widget.onRemove,
                ),
              ],
            ),
            const Divider(),
            ..._fields(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _fields(BuildContext context) {
    final type = e['type']?.toString() ?? 'word_match';
    switch (type) {
      case 'word_match':
        return [
          _num('XP', 'xp'),
          _two('instruction_ru', 'instruction_en', 'Инструкция RU', 'Instruction EN'),
          _two('hint_ru', 'hint_en', 'Подсказка RU', 'Hint EN'),
          const Text('Пары (isv_lat / isv_cyr / ru / en):'),
          const SizedBox(height: 6),
          ..._pairsEditor(),
        ];
      case 'multiple_choice':
        return [
          _num('XP', 'xp'),
          _two('instruction_ru', 'instruction_en', 'Инструкция RU', 'Instruction EN'),
          _two('question_isv_lat', 'question_isv_cyr', 'Вопрос ISV lat', 'Вопрос ISV kir'),
          _two('hint_ru', 'hint_en', 'Подсказка RU', 'Hint EN'),
          _intField('correct_index', 'Индекс верного (0–3)'),
          const Text('Варианты RU (4 строки):'),
          ..._fourLines('options_ru'),
          const Text('Варианты EN (4 строки):'),
          ..._fourLines('options_en'),
        ];
      case 'fill_blank':
        return [
          _num('XP', 'xp'),
          _two('instruction_ru', 'instruction_en', 'Инструкция RU', 'Instruction EN'),
          _two('sentence_isv_lat', 'sentence_isv_cyr', 'Предложение lat', 'Предложение kir'),
          _two('answer_isv_lat', 'answer_isv_cyr', 'Ответ lat', 'Ответ kir'),
          _two('translation_ru', 'translation_en', 'Перевод RU', 'Translation EN'),
          _two('hint_ru', 'hint_en', 'Подсказка RU', 'Hint EN'),
        ];
      case 'text_input':
        return [
          _num('XP', 'xp'),
          _two('instruction_ru', 'instruction_en', 'Инструкция RU', 'Instruction EN'),
          _two('prompt_ru', 'prompt_en', 'Подсказка поля RU', 'Prompt EN'),
          _two('answer_isv_lat', 'answer_isv_cyr', 'Ответ lat', 'Ответ kir'),
          _two('hint_ru', 'hint_en', 'Подсказка RU', 'Hint EN'),
        ];
      default:
        return [Text('Неизвестный тип: $type')];
    }
  }

  Widget _num(String label, String key) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        initialValue: '${e[key] ?? 10}',
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        onChanged: (v) => e[key] = int.tryParse(v) ?? 10,
      ),
    );
  }

  Widget _two(String k1, String k2, String l1, String l2) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextFormField(
              initialValue: e[k1]?.toString() ?? '',
              decoration: InputDecoration(
                labelText: l1,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (v) => e[k1] = v,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              initialValue: e[k2]?.toString() ?? '',
              decoration: InputDecoration(
                labelText: l2,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (v) => e[k2] = v,
            ),
          ),
        ],
      ),
    );
  }

  Widget _intField(String key, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        initialValue: '${e[key] ?? 0}',
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        onChanged: (v) => e[key] = int.tryParse(v) ?? 0,
      ),
    );
  }

  List<Widget> _fourLines(String key) {
    final list = (e[key] as List<dynamic>?)?.map((x) => x.toString()).toList() ??
        ['', '', '', ''];
    while (list.length < 4) {
      list.add('');
    }
    e[key] = list;
    return List.generate(4, (i) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: TextFormField(
          key: ValueKey('$key$i'),
          initialValue: list[i],
          decoration: InputDecoration(
            labelText: '#${i + 1}',
            border: const OutlineInputBorder(),
          ),
          onChanged: (v) => list[i] = v,
        ),
      );
    });
  }

  List<Widget> _pairsEditor() {
    final pairs = (e['pairs'] as List<dynamic>?)
            ?.map((p) => Map<String, dynamic>.from(p as Map))
            .toList() ??
        <Map<String, dynamic>>[];
    e['pairs'] = pairs;
    return [
      ...pairs.asMap().entries.map((en) {
        final i = en.key;
        final p = en.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: p['isv_lat']?.toString() ?? '',
                  decoration: const InputDecoration(
                    labelText: 'isv_lat',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) => p['isv_lat'] = v,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: TextFormField(
                  initialValue: p['isv_cyr']?.toString() ?? '',
                  decoration: const InputDecoration(
                    labelText: 'isv_cyr',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) => p['isv_cyr'] = v,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: TextFormField(
                  initialValue: p['ru']?.toString() ?? '',
                  decoration: const InputDecoration(
                    labelText: 'ru',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) => p['ru'] = v,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: TextFormField(
                  initialValue: p['en']?.toString() ?? '',
                  decoration: const InputDecoration(
                    labelText: 'en',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) => p['en'] = v,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  pairs.removeAt(i);
                  setState(() {});
                },
              ),
            ],
          ),
        );
      }),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () {
            pairs.add({
              'isv_lat': '',
              'isv_cyr': '',
              'ru': '',
              'en': '',
            });
            setState(() {});
          },
          icon: const Icon(Icons.add),
          label: const Text('Пара'),
        ),
      ),
    ];
  }
}
