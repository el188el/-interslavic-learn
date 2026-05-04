import 'package:flutter/material.dart';

import '../course_repository.dart';
import '../exercise_templates.dart';
import '../widgets/exercise_card_editor.dart';
import '../widgets/theory_blocks_editor.dart';

class LessonEditorPage extends StatefulWidget {
  const LessonEditorPage({
    super.key,
    required this.lesson,
    required this.categories,
  });

  final Map<String, dynamic> lesson;
  final List<Map<String, dynamic>> categories;

  @override
  State<LessonEditorPage> createState() => _LessonEditorPageState();
}

class _LessonEditorPageState extends State<LessonEditorPage>
    with SingleTickerProviderStateMixin {
  late Map<String, dynamic> _lesson;
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _lesson = CourseRepository.cloneMap(widget.lesson);
    _ensureShapes();
    _tab = TabController(length: 3, vsync: this);
  }

  void _ensureShapes() {
    _lesson['theory'] ??= <String, dynamic>{
      'title_ru': '',
      'title_en': '',
      'blocks': <Map<String, dynamic>>[],
    };
    final th = _lesson['theory'] as Map<String, dynamic>;
    th['blocks'] = (th['blocks'] as List<dynamic>?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        <Map<String, dynamic>>[];
    _lesson['exercises'] = (_lesson['exercises'] as List<dynamic>?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        <Map<String, dynamic>>[];
  }

  List<Map<String, dynamic>> get _blocks =>
      (_lesson['theory'] as Map<String, dynamic>)['blocks']!
          as List<Map<String, dynamic>>;

  List<Map<String, dynamic>> get _exercises =>
      _lesson['exercises'] as List<Map<String, dynamic>>;

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<bool> _confirmDiscard() async {
    final r = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Закрыть без сохранения?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Выйти')),
        ],
      ),
    );
    return r == true;
  }

  @override
  Widget build(BuildContext context) {
    final th = _lesson['theory'] as Map<String, dynamic>;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _confirmDiscard().then((ok) {
          if (ok && context.mounted) Navigator.of(context).pop();
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_lesson['title_ru']?.toString().isNotEmpty == true
              ? _lesson['title_ru'] as String
              : 'Урок'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              if (await _confirmDiscard() && mounted) Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (await _confirmDiscard() && mounted) Navigator.pop(context);
              },
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, CourseRepository.cloneMap(_lesson)),
              child: const Text('Сохранить'),
            ),
          ],
          bottom: TabBar(
            controller: _tab,
            tabs: const [
              Tab(text: 'Урок'),
              Tab(text: 'Теория'),
              Tab(text: 'Упражнения'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tab,
          children: [
            _metaTab(),
            _theoryTab(th),
            _exercisesTab(),
          ],
        ),
      ),
    );
  }

  Widget _metaTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextFormField(
          initialValue: _lesson['id']?.toString() ?? '',
          decoration: const InputDecoration(
            labelText: 'ID урока (латиница, уникально)',
            border: OutlineInputBorder(),
          ),
          onChanged: (v) => _lesson['id'] = v,
        ),
        const SizedBox(height: 12),
        if (widget.categories.isEmpty)
          const Text('Сначала создайте категорию на главной.')
        else
          DropdownButtonFormField<String>(
            value: _resolvedCategoryId(),
            decoration: const InputDecoration(
              labelText: 'Категория',
              border: OutlineInputBorder(),
            ),
            items: widget.categories
                .map(
                  (c) => DropdownMenuItem(
                    value: c['id'] as String,
                    child: Text('${c['id']} — ${c['title_ru']}'),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _lesson['category_id'] = v);
            },
          ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: '${_lesson['order'] ?? 0}',
          decoration: const InputDecoration(
            labelText: 'Порядок (sort_order)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (v) => _lesson['order'] = int.tryParse(v) ?? 0,
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: _lesson['title_ru']?.toString() ?? '',
          decoration: const InputDecoration(
            labelText: 'Название RU',
            border: OutlineInputBorder(),
          ),
          onChanged: (v) => _lesson['title_ru'] = v,
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: _lesson['title_en']?.toString() ?? '',
          decoration: const InputDecoration(
            labelText: 'Title EN',
            border: OutlineInputBorder(),
          ),
          onChanged: (v) => _lesson['title_en'] = v,
        ),
      ],
    );
  }

  List<String> get _categoryIds =>
      widget.categories.map((c) => c['id'] as String).toList();

  String? _resolvedCategoryId() {
    final ids = _categoryIds;
    if (ids.isEmpty) return null;
    final cur = _lesson['category_id']?.toString();
    if (cur != null && ids.contains(cur)) return cur;
    return ids.first;
  }

  Widget _theoryTab(Map<String, dynamic> th) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextFormField(
          initialValue: th['title_ru']?.toString() ?? '',
          decoration: const InputDecoration(
            labelText: 'Заголовок теории RU',
            border: OutlineInputBorder(),
          ),
          onChanged: (v) => th['title_ru'] = v,
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: th['title_en']?.toString() ?? '',
          decoration: const InputDecoration(
            labelText: 'Theory title EN',
            border: OutlineInputBorder(),
          ),
          onChanged: (v) => th['title_en'] = v,
        ),
        const SizedBox(height: 20),
        TheoryBlocksEditor(
          blocks: _blocks,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _exercisesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Text(
              'Упражнения (${_exercises.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            PopupMenuButton<String>(
              onSelected: (type) {
                setState(() {
                  _exercises.add(templateExercise(type));
                });
              },
              itemBuilder: (c) => kExerciseTypes
                  .map((t) => PopupMenuItem(value: t, child: Text('Добавить: $t')))
                  .toList(),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.add_circle_outline),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._exercises.asMap().entries.map((en) {
          final i = en.key;
          final ex = en.value;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Column(
                  children: [
                    IconButton(
                      tooltip: 'Выше',
                      icon: const Icon(Icons.arrow_upward),
                      onPressed: i == 0
                          ? null
                          : () {
                              setState(() {
                                final x = _exercises.removeAt(i);
                                _exercises.insert(i - 1, x);
                              });
                            },
                    ),
                    IconButton(
                      tooltip: 'Ниже',
                      icon: const Icon(Icons.arrow_downward),
                      onPressed: i >= _exercises.length - 1
                          ? null
                          : () {
                              setState(() {
                                final x = _exercises.removeAt(i);
                                _exercises.insert(i + 1, x);
                              });
                            },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ExerciseCardEditor(
                  key: ValueKey('ex_$i'),
                  exercise: ex,
                  onChangedType: (newType) {
                    setState(() {
                      _exercises[i] = templateExercise(newType);
                    });
                  },
                  onRemove: () {
                    setState(() => _exercises.removeAt(i));
                  },
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}
