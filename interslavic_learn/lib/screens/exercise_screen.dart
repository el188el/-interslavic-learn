import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/lesson.dart';
import '../models/exercise.dart';
import '../models/lesson_checkpoint.dart';
import '../providers/app_providers.dart';
import '../services/progress_service.dart';
import '../services/sync_service.dart';
import '../services/supabase_service.dart';
import '../widgets/adaptive_body.dart';
import '../widgets/app_chrome_background.dart';
import '../widgets/glass_panel.dart';
import '../widgets/theory_peek_sheet.dart';
import '../widgets/word_match_exercise.dart';
import '../widgets/multiple_choice_exercise.dart';
import '../widgets/fill_blank_exercise.dart';
import '../widgets/text_input_exercise.dart';
import 'lesson_complete_screen.dart';

class ExerciseScreen extends ConsumerStatefulWidget {
  final Lesson lesson;
  const ExerciseScreen({super.key, required this.lesson});

  @override
  ConsumerState<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends ConsumerState<ExerciseScreen> {
  int _currentIndex = 0;
  late Set<int> _xpGrantedExerciseIndices;
  late final bool _lessonWasAlreadyCompleted;
  bool _lessonFlowFinished = false;

  List<Exercise> get exercises => widget.lesson.exercises;

  ProgressService get _progress => ref.read(progressServiceProvider);

  @override
  void initState() {
    super.initState();
    final progress = ref.read(userProgressProvider);
    _lessonWasAlreadyCompleted =
        progress.completedLessons.contains(widget.lesson.id);
    final cp = _lessonWasAlreadyCompleted
        ? null
        : _progress.lessonCheckpoint(widget.lesson.id);
    _xpGrantedExerciseIndices = {
      ...?cp?.xpGrantedExerciseIndices,
    };
    final n = exercises.length;
    if (n == 0) {
      _currentIndex = 0;
    } else {
      final raw = cp?.resumeExerciseIndex ?? 0;
      _currentIndex = raw.clamp(0, n - 1);
    }
  }

  void _refreshProgressProvider() {
    ref.read(userProgressProvider.notifier).refresh();
  }

  Future<void> _persistCheckpoint() async {
    if (_lessonWasAlreadyCompleted || exercises.isEmpty) return;
    await _progress.saveLessonCheckpoint(
      widget.lesson.id,
      LessonCheckpoint(
        resumeExerciseIndex: _currentIndex,
        xpGrantedExerciseIndices: _xpGrantedExerciseIndices.toList()..sort(),
      ),
    );
    _refreshProgressProvider();
  }

  Future<void> _clearCheckpoint() async {
    await _progress.clearLessonCheckpoint(widget.lesson.id);
    _refreshProgressProvider();
  }

  void _onExerciseComplete(bool correct, int xp) {
    if (!correct) return;

    final i = _currentIndex;
    final newlyGranted = !_xpGrantedExerciseIndices.contains(i);
    if (newlyGranted) {
      _xpGrantedExerciseIndices.add(i);
      if (!_lessonWasAlreadyCompleted) {
        ref.read(userProgressProvider.notifier).addXp(xp);
      }
    }

    Future.delayed(const Duration(milliseconds: 800), () async {
      if (!mounted) return;
      if (_currentIndex < exercises.length - 1) {
        setState(() => _currentIndex++);
        await _persistCheckpoint();
      } else {
        await _finishLessonRun();
      }
    });
  }

  Future<void> _finishLessonRun() async {
    _lessonFlowFinished = true;
    final scoreSum = _xpGrantedExerciseIndices.fold<int>(
        0, (a, i) => a + exercises[i].xp);
    ref.read(userProgressProvider.notifier).updateStreak();
    ref
        .read(userProgressProvider.notifier)
        .completeLesson(widget.lesson.id, scoreSum);

    await _clearCheckpoint();

    final mode = ref.read(sessionModeProvider);
    if (mode == SessionMode.cloud && isSupabaseConfigured) {
      unawaited(
        SyncService(ref.read(progressServiceProvider))
            .pushLocalProgressToCloud(),
      );
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => LessonCompleteScreen(
          lesson: widget.lesson,
          xpEarned: scoreSum,
          correctAnswers: _xpGrantedExerciseIndices.length,
          totalExercises: exercises.length,
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (!_lessonFlowFinished &&
        !_lessonWasAlreadyCompleted &&
        exercises.isNotEmpty) {
      unawaited(_persistCheckpoint());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final useCyrillic = ref.watch(useCyrillicProvider);

    if (exercises.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.lesson.title(locale))),
        body: AppChromeBackground(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Text(
                locale == 'ru'
                    ? 'Нет упражнений'
                    : 'No exercises available',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    final exercise = exercises[_currentIndex];
    final progress = (_currentIndex + 1) / exercises.length;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop &&
            !_lessonFlowFinished &&
            !_lessonWasAlreadyCompleted &&
            exercises.isNotEmpty) {
          unawaited(_persistCheckpoint());
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(
            '${locale == 'ru' ? 'Упражнение' : 'Exercise'} ${_currentIndex + 1}/${exercises.length}',
          ),
          actions: [
            IconButton(
              tooltip:
                  locale == 'ru' ? 'Подсмотреть теорию' : 'Peek at theory',
              icon: const Icon(Icons.menu_book_outlined),
              onPressed: () => showTheoryPeekSheet(context, widget.lesson),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Builder(
                builder: (context) {
                  final cs = Theme.of(context).colorScheme;
                  return GlassPanel(
                    padding: const EdgeInsets.all(4),
                    borderRadius: 14,
                    child: SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: false, label: Text('Lat')),
                        ButtonSegment(value: true, label: Text('Кир')),
                      ],
                      selected: {useCyrillic},
                      onSelectionChanged: (v) {
                        ref.read(useCyrillicProvider.notifier).state =
                            v.first;
                      },
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        side: WidgetStateProperty.all(BorderSide.none),
                        backgroundColor:
                            WidgetStateProperty.resolveWith((s) {
                          if (s.contains(WidgetState.selected)) {
                            return cs.primary.withValues(alpha: 0.35);
                          }
                          return Colors.transparent;
                        }),
                        foregroundColor:
                            WidgetStateProperty.all(cs.onSurface),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        body: AppChromeBackground(
          child: Column(
            children: [
              LinearProgressIndicator(value: progress),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
                child: Text(
                  locale == 'ru'
                      ? 'Выберите верный ответ — откроется следующее упражнение.'
                      : 'Answer correctly to go to the next exercise.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withValues(alpha: 0.9),
                      ),
                ),
              ),
              Expanded(
                child: AdaptiveBody(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(22, 10, 22, 20),
                    child: _buildExerciseWidget(
                        exercise, locale, useCyrillic),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseWidget(
      Exercise exercise, String locale, bool useCyrillic) {
    switch (exercise.type) {
      case 'word_match':
        return WordMatchExercise(
          key: ValueKey('match_$_currentIndex'),
          exercise: exercise,
          locale: locale,
          useCyrillic: useCyrillic,
          onComplete: _onExerciseComplete,
        );
      case 'multiple_choice':
        return MultipleChoiceExercise(
          key: ValueKey('mc_$_currentIndex'),
          exercise: exercise,
          locale: locale,
          useCyrillic: useCyrillic,
          onComplete: _onExerciseComplete,
        );
      case 'fill_blank':
        return FillBlankExercise(
          key: ValueKey('fill_$_currentIndex'),
          exercise: exercise,
          locale: locale,
          useCyrillic: useCyrillic,
          onComplete: _onExerciseComplete,
        );
      case 'text_input':
        return TextInputExercise(
          key: ValueKey('input_$_currentIndex'),
          exercise: exercise,
          locale: locale,
          useCyrillic: useCyrillic,
          onComplete: _onExerciseComplete,
        );
      default:
        return Center(
          child: Text(
              '${locale == 'ru' ? 'Неизвестный тип' : 'Unknown type'}: ${exercise.type}'),
        );
    }
  }
}
