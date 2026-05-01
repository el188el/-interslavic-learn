import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../providers/app_providers.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(category.title(locale)),
      ),
      body: lessons.isEmpty
          ? Center(
              child: Text(
                locale == 'ru'
                    ? 'Уроки скоро появятся!'
                    : 'Lessons coming soon!',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                final isCompleted =
                    progress.completedLessons.contains(lesson.id);
                final score = progress.lessonScores[lesson.id];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: isCompleted
                          ? Colors.green
                          : Theme.of(context).colorScheme.primaryContainer,
                      child: isCompleted
                          ? const Icon(Icons.check, color: Colors.white)
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                    ),
                    title: Text(
                      lesson.title(locale),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: isCompleted && score != null
                        ? Text(
                            locale == 'ru'
                                ? 'Результат: $score XP'
                                : 'Score: $score XP',
                          )
                        : Text(
                            locale == 'ru'
                                ? '${lesson.exercises.length} упражнений'
                                : '${lesson.exercises.length} exercises',
                          ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TheoryScreen(lesson: lesson),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
