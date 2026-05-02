import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/category.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/app_chrome_background.dart';
import '../widgets/glass_panel.dart';
import 'theory_screen.dart';

class CategoryLessonsScreen extends ConsumerWidget {
  final Category category;
  const CategoryLessonsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final dataService = ref.watch(dataServiceProvider);
    final progress = ref.watch(userProgressProvider);
    final lessons = dataService.lessonsForCategory(category.id);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          category.title(locale),
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, letterSpacing: -0.3),
        ),
      ),
      body: lessons.isEmpty
          ? AppChromeBackground(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: GlassPanel(
                    padding: const EdgeInsets.all(28),
                    child: Text(
                      locale == 'ru'
                          ? 'Уроки скоро появятся!'
                          : 'Lessons coming soon!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : AppChromeBackground(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
                itemCount: lessons.length,
                itemBuilder: (context, index) {
                  final lesson = lessons[index];
                  final isCompleted =
                      progress.completedLessons.contains(lesson.id);
                  final score = progress.lessonScores[lesson.id];
                  final checkpoint = progress.lessonCheckpoint(lesson.id);
                  final hasPartial = checkpoint != null &&
                      !isCompleted &&
                      (checkpoint.resumeExerciseIndex > 0 ||
                          checkpoint.xpGrantedExerciseIndices.isNotEmpty);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GlassPanel(
                      padding: EdgeInsets.zero,
                      borderRadius: 22,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => TheoryScreen(lesson: lesson),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _LessonIndexOrb(
                                  index: index + 1,
                                  completed: isCompleted,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        lesson.title(locale),
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          height: 1.25,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        isCompleted && score != null
                                            ? (locale == 'ru'
                                                ? 'Результат: $score XP'
                                                : 'Score: $score XP')
                                            : hasPartial
                                                ? (locale == 'ru'
                                                    ? 'Продолжить: упражнение ${checkpoint.resumeExerciseIndex + 1} · ${lesson.exercises.length} всего'
                                                    : 'Continue: exercise ${checkpoint.resumeExerciseIndex + 1} · ${lesson.exercises.length} total')
                                                : (locale == 'ru'
                                                    ? '${lesson.exercises.length} упражнений'
                                                    : '${lesson.exercises.length} exercises'),
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 18,
                                  color: cs.primary.withValues(alpha: 0.9),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _LessonIndexOrb extends StatelessWidget {
  const _LessonIndexOrb({
    required this.index,
    required this.completed,
  });

  final int index;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const size = 48.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: completed
            ? LinearGradient(
                colors: [
                  cs.primary,
                  cs.primary.withValues(alpha: 0.82),
                ],
              )
            : LinearGradient(
                colors: [
                  cs.primary,
                  DuoColors.primaryGreenDeep,
                ],
              ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: completed
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 26)
          : Text(
              '$index',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
    );
  }
}
