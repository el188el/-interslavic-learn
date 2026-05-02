import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/data_service.dart';
import '../services/preferences_service.dart';
import '../services/progress_service.dart';
import '../models/user_progress.dart';

/// Переопределяется в `main` через `ProviderScope`.
final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  throw StateError('preferencesServiceProvider не инициализирован');
});

/// Locale: `ru` | `en`
final localeProvider = StateProvider<String>((ref) => 'ru');

/// Кириллица для межславянского.
final useCyrillicProvider = StateProvider<bool>((ref) => false);

/// Тема интерфейса: системная / светлая / тёмная (персистится в SharedPreferences).
enum AppThemePreference { system, light, dark }

AppThemePreference appThemePreferenceFromRaw(String? raw) {
  switch (raw) {
    case 'light':
      return AppThemePreference.light;
    case 'dark':
      return AppThemePreference.dark;
    default:
      return AppThemePreference.system;
  }
}

ThemeMode themeModeFromPreference(AppThemePreference p) {
  switch (p) {
    case AppThemePreference.light:
      return ThemeMode.light;
    case AppThemePreference.dark:
      return ThemeMode.dark;
    case AppThemePreference.system:
      return ThemeMode.system;
  }
}

final themePreferenceProvider =
    StateProvider<AppThemePreference>((ref) => AppThemePreference.system);

/// Гость — только локальный прогресс. Облако — вход по email (Supabase).
enum SessionMode { guest, cloud }

final sessionModeProvider = StateProvider<SessionMode>((ref) => SessionMode.guest);

/// Онбординг завершён (гость или аккаунт). Инициализируется из SharedPreferences.
final onboardingCompleteProvider = StateProvider<bool>((ref) => false);

/// Баннер «режим гостя» скрыт пользователем (SharedPreferences).
final guestBannerDismissedProvider = StateProvider<bool>((ref) => false);

final dataServiceProvider = ChangeNotifierProvider<DataService>((ref) {
  final s = DataService();
  ref.onDispose(s.dispose);
  return s;
});

final progressServiceProvider =
    Provider<ProgressService>((ref) => ProgressService());

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

  Future<void> setDisplayName(String name) async {
    await _service.setDisplayName(name);
    state = _service.getProgress();
  }
}

final userProgressProvider =
    StateNotifierProvider<UserProgressNotifier, UserProgress>((ref) {
  final service = ref.watch(progressServiceProvider);
  return UserProgressNotifier(service);
});
