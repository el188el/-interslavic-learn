import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lesson.dart';
import '../providers/app_providers.dart';

class LessonCompleteScreen extends ConsumerWidget {
  final Lesson lesson;
  final int xpEarned;
  final int correctAnswers;
  final int totalExercises;

  const LessonCompleteScreen({
    super.key,
    required this.lesson,
    required this.xpEarned,
    required this.correctAnswers,
    required this.totalExercises,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final progress = ref.watch(userProgressProvider);
    final percentage =
        totalExercises > 0 ? (correctAnswers / totalExercises * 100).round() : 0;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.celebration,
                  size: 80,
                  color: Colors.amber,
                ),
                const SizedBox(height: 24),
                Text(
                  locale == 'ru' ? 'Урок завершён!' : 'Lesson Complete!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 32),

                // Stats cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatCard(
                      icon: Icons.star,
                      color: Colors.amber,
                      value: '+$xpEarned',
                      label: 'XP',
                    ),
                    _StatCard(
                      icon: Icons.check_circle,
                      color: Colors.green,
                      value: '$percentage%',
                      label: locale == 'ru' ? 'Точность' : 'Accuracy',
                    ),
                    _StatCard(
                      icon: Icons.local_fire_department,
                      color: Colors.deepOrange,
                      value: '${progress.currentStreak}',
                      label: locale == 'ru' ? 'Серия' : 'Streak',
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Text(
                  '$correctAnswers / $totalExercises ${locale == 'ru' ? 'правильно' : 'correct'}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.amber),
                        const SizedBox(width: 8),
                        Text(
                          '${locale == 'ru' ? 'Всего XP' : 'Total XP'}: ${progress.totalXp}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context)
                        ..pop()
                        ..pop();
                    },
                    child: Text(
                      locale == 'ru' ? 'Продолжить' : 'Continue',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
