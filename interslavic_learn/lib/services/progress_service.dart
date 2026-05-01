import 'package:hive/hive.dart';
import '../models/user_progress.dart';

class ProgressService {
  static const String _boxName = 'user_progress';
  late Box<UserProgress> _box;

  Future<void> init() async {
    _box = await Hive.openBox<UserProgress>(_boxName);
  }

  UserProgress getProgress() {
    if (_box.isEmpty) {
      final progress = UserProgress();
      _box.put('current', progress);
      return progress;
    }
    return _box.get('current')!;
  }

  Future<void> addXp(int xp) async {
    final progress = getProgress();
    progress.addXp(xp);
  }

  Future<void> completeLesson(String lessonId, int score) async {
    final progress = getProgress();
    progress.completeLesson(lessonId, score);
  }

  Future<void> updateStreak() async {
    final progress = getProgress();
    progress.updateStreak();
  }

  bool isLessonCompleted(String lessonId) {
    final progress = getProgress();
    return progress.completedLessons.contains(lessonId);
  }

  int get totalXp => getProgress().totalXp;
  int get currentStreak => getProgress().currentStreak;
  int get bestStreak => getProgress().bestStreak;
}
