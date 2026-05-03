import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/lesson.dart';
import '../providers/app_providers.dart';
import '../widgets/app_chrome_background.dart';
import '../widgets/glass_panel.dart';
import '../widgets/gradient_cta_button.dart';
import '../widgets/lesson_theory_blocks.dart';
import 'exercise_screen.dart';

class TheoryScreen extends ConsumerWidget {
  final Lesson lesson;
  const TheoryScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final useCyrillic = ref.watch(useCyrillicProvider);
    final progress = ref.watch(userProgressProvider);
    final checkpoint = progress.lessonCheckpoint(lesson.id);
    final lessonIncomplete = !progress.completedLessons.contains(lesson.id);
    final hasSavedProgress = checkpoint != null &&
        lessonIncomplete &&
        (checkpoint.resumeExerciseIndex > 0 ||
            checkpoint.xpGrantedExerciseIndices.isNotEmpty);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          lesson.theory.title(locale),
          style:
              GoogleFonts.inter(fontWeight: FontWeight.w700, letterSpacing: -0.3),
        ),
        actions: [
          _ScriptToggle(useCyrillic: useCyrillic, ref: ref),
        ],
      ),
      body: AppChromeBackground(
        child: Column(
          children: [
            if (hasSavedProgress)
              Material(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.45),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.play_circle_outline_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          locale == 'ru'
                              ? 'Сохранён прогресс: упражнение ${checkpoint.resumeExerciseIndex + 1}.'
                              : 'Saved progress: exercise ${checkpoint.resumeExerciseIndex + 1}.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
                children: [
                  for (final block in lesson.theory.blocks)
                    LessonTheoryBlockWidget(
                      block: block,
                      locale: locale,
                      useCyrillic: useCyrillic,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 22),
              child: SafeArea(
                top: false,
                child: GradientCtaButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => ExerciseScreen(lesson: lesson),
                      ),
                    );
                  },
                  label: locale == 'ru'
                      ? (hasSavedProgress
                          ? 'Далее: продолжить упражнения'
                          : 'Далее: упражнения')
                      : (hasSavedProgress
                          ? 'Next: continue exercises'
                          : 'Next: exercises'),
                ),
              ),
            ),
          ],
        ),
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
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GlassPanel(
        padding: const EdgeInsets.all(4),
        borderRadius: 14,
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
            side: WidgetStateProperty.all(BorderSide.none),
            backgroundColor: WidgetStateProperty.resolveWith((s) {
              if (s.contains(WidgetState.selected)) {
                return cs.primary.withValues(alpha: 0.35);
              }
              return Colors.transparent;
            }),
            foregroundColor: WidgetStateProperty.all(cs.onSurface),
          ),
        ),
      ),
    );
  }
}
