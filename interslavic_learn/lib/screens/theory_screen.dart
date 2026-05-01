import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lesson.dart';
import '../providers/app_providers.dart';
import 'exercise_screen.dart';

class TheoryScreen extends ConsumerWidget {
  final Lesson lesson;
  const TheoryScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final useCyrillic = ref.watch(useCyrillicProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.theory.title(locale)),
        actions: [
          _ScriptToggle(useCyrillic: useCyrillic, ref: ref),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final block in lesson.theory.blocks)
                  _TheoryBlockWidget(
                    block: block,
                    locale: locale,
                    useCyrillic: useCyrillic,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExerciseScreen(lesson: lesson),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: Text(
                  locale == 'ru'
                      ? 'Начать упражнения'
                      : 'Start Exercises',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScriptToggle extends StatelessWidget {
  final bool useCyrillic;
  final WidgetRef ref;
  const _ScriptToggle({required this.useCyrillic, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: SegmentedButton<bool>(
        segments: const [
          ButtonSegment(value: false, label: Text('Lat')),
          ButtonSegment(value: true, label: Text('Кир')),
        ],
        selected: {useCyrillic},
        onSelectionChanged: (v) {
          ref.read(useCyrillicProvider.notifier).state = v.first;
        },
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

class _TheoryBlockWidget extends StatelessWidget {
  final TheoryBlock block;
  final String locale;
  final bool useCyrillic;

  const _TheoryBlockWidget({
    required this.block,
    required this.locale,
    required this.useCyrillic,
  });

  @override
  Widget build(BuildContext context) {
    switch (block.type) {
      case 'text':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            block.content(locale) ?? '',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
        );

      case 'tip':
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  block.content(locale) ?? '',
                  style: TextStyle(color: Colors.blue.shade900),
                ),
              ),
            ],
          ),
        );

      case 'vocabulary_table':
        final items = block.items ?? [];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Table(
              border: TableBorder.all(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.5),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        useCyrillic
                            ? 'Меджусловјанскы'
                            : 'Medžuslovjansky',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        locale == 'ru' ? 'Перевод' : 'Translation',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                for (final item in items)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          useCyrillic
                              ? (item['isv_cyr'] ?? item['isv_lat'] ?? '')
                                  as String
                              : (item['isv_lat'] ?? '') as String,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          (locale == 'ru'
                                  ? item['ru']
                                  : item['en']) as String? ??
                              '',
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );

      case 'grammar_table':
        final rows = block.rows ?? [];
        if (rows.isEmpty) return const SizedBox.shrink();
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Table(
                border: TableBorder.all(color: Colors.grey.shade300),
                defaultColumnWidth: const IntrinsicColumnWidth(),
                children: rows.asMap().entries.map((entry) {
                  final isHeader = entry.key == 0;
                  return TableRow(
                    decoration: isHeader
                        ? BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.5),
                          )
                        : null,
                    children: entry.value
                        .map(
                          (cell) => Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              cell,
                              style: isHeader
                                  ? const TextStyle(
                                      fontWeight: FontWeight.bold)
                                  : null,
                            ),
                          ),
                        )
                        .toList(),
                  );
                }).toList(),
              ),
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
