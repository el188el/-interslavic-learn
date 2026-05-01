import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/data_service.dart';
import '../services/progress_service.dart';
import '../models/user_progress.dart';

// Locale: 'ru' or 'en'
final localeProvider = StateProvider<String>((ref) => 'ru');

// Script: true = Cyrillic, false = Latin
final useCyrillicProvider = StateProvider<bool>((ref) => false);

// Data service singleton
final dataServiceProvider = Provider<DataService>((ref) => DataService());

// Progress service singleton
final progressServiceProvider =
    Provider<ProgressService>((ref) => ProgressService());

// User progress notifier
class UserProgressNotifier extends StateNotifier<UserProgress> {
  final ProgressService _service;

  UserProgressNotifier(this._service) : super(_service.getProgress());

  void addXp(int xp) {
    _service.addXp(xp);
    state = _service.getProgress().copyWith();
  }

  void completeLesson(String lessonId, int score) {
    _service.completeLesson(lessonId, score);
    state = _service.getProgress().copyWith();
  }

  void updateStreak() {
    _service.updateStreak();
    state = _service.getProgress().copyWith();
  }

  void refresh() {
    state = _service.getProgress().copyWith();
  }
}

final userProgressProvider =
    StateNotifierProvider<UserProgressNotifier, UserProgress>((ref) {
  final service = ref.watch(progressServiceProvider);
  return UserProgressNotifier(service);
});
