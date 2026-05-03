import 'package:hive/hive.dart';
import '../models/lesson_checkpoint.dart';
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

  Future<void> setDisplayName(String name) async {
    final progress = getProgress();
    final t = name.trim();
    if (t.isEmpty) return;
    progress.displayName = t.length > 48 ? t.substring(0, 48) : t;
    await progress.save();
  }

  bool isLessonCompleted(String lessonId) {
    final progress = getProgress();
    return progress.completedLessons.contains(lessonId);
  }

  int get totalXp => getProgress().totalXp;
  int get currentStreak => getProgress().currentStreak;
  int get bestStreak => getProgress().bestStreak;

  LessonCheckpoint? lessonCheckpoint(String lessonId) =>
      getProgress().lessonCheckpoint(lessonId);

  Future<void> saveLessonCheckpoint(
      String lessonId, LessonCheckpoint checkpoint) async {
    final p = getProgress();
    p.setLessonCheckpoint(lessonId, checkpoint);
    await p.save();
  }

  Future<void> clearLessonCheckpoint(String lessonId) async {
    final p = getProgress();
    p.clearLessonCheckpoint(lessonId);
    await p.save();
  }
}
