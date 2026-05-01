import 'package:hive/hive.dart';

part 'user_progress.g.dart';

@HiveType(typeId: 0)
class UserProgress extends HiveObject {
  @HiveField(0)
  String odUserId;

  @HiveField(1)
  int totalXp;

  @HiveField(2)
  int currentStreak;

  @HiveField(3)
  int bestStreak;

  @HiveField(4)
  String lastActiveDate;

  @HiveField(5)
  List<String> completedLessons;

  @HiveField(6)
  Map<String, int> lessonScores;

  @HiveField(7)
  String displayName;

  @HiveField(8)
  bool isPremium;

  UserProgress({
    this.odUserId = '',
    this.totalXp = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastActiveDate = '',
    List<String>? completedLessons,
    Map<String, int>? lessonScores,
    this.displayName = 'Ученик',
    this.isPremium = false,
  })  : completedLessons = completedLessons ?? [],
        lessonScores = lessonScores ?? {};

  void addXp(int xp) {
    totalXp += xp;
    save();
  }

  void completeLesson(String lessonId, int score) {
    if (!completedLessons.contains(lessonId)) {
      completedLessons.add(lessonId);
    }
    lessonScores[lessonId] = score;
    save();
  }

  void updateStreak() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (lastActiveDate == today) return;

    final yesterday = DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .substring(0, 10);

    if (lastActiveDate == yesterday) {
      currentStreak++;
    } else {
      currentStreak = 1;
    }
    if (currentStreak > bestStreak) {
      bestStreak = currentStreak;
    }
    lastActiveDate = today;
    save();
  }
}
