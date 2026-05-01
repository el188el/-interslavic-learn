import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lesson.dart';
import '../models/exercise.dart';
import '../providers/app_providers.dart';
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
  int _totalXpEarned = 0;
  int _correctAnswers = 0;

  List<Exercise> get exercises => widget.lesson.exercises;

  void _onExerciseComplete(bool correct, int xp) {
    if (correct) {
      _totalXpEarned += xp;
      _correctAnswers++;
      ref.read(userProgressProvider.notifier).addXp(xp);
    }

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      if (_currentIndex < exercises.length - 1) {
        setState(() => _currentIndex++);
      } else {
        ref.read(userProgressProvider.notifier).updateStreak();
        ref
            .read(userProgressProvider.notifier)
            .completeLesson(widget.lesson.id, _totalXpEarned);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LessonCompleteScreen(
              lesson: widget.lesson,
              xpEarned: _totalXpEarned,
              correctAnswers: _correctAnswers,
              totalExercises: exercises.length,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final useCyrillic = ref.watch(useCyrillicProvider);

    if (exercises.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.lesson.title(locale))),
        body: Center(
          child: Text(locale == 'ru'
              ? 'Нет упражнений'
              : 'No exercises available'),
        ),
      );
    }

    final exercise = exercises[_currentIndex];
    final progress = (_currentIndex + 1) / exercises.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${locale == 'ru' ? 'Упражнение' : 'Exercise'} ${_currentIndex + 1}/${exercises.length}',
        ),
        actions: [
          Padding(
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
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: progress),
          Expanded(
            child: _buildExerciseWidget(exercise, locale, useCyrillic),
          ),
        ],
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
          child: Text('${locale == 'ru' ? 'Неизвестный тип' : 'Unknown type'}: ${exercise.type}'),
        );
    }
  }
}
