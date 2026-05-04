import 'package:shared_preferences/shared_preferences.dart';

/// Persisted UI preferences (locale, script).
class PreferencesService {
  PreferencesService._(this._p);

  final SharedPreferences _p;

  static const _kLocale = 'pref_locale';
  static const _kCyrillic = 'pref_use_cyrillic';
  static const _kOnboarding = 'pref_onboarding_complete';
  static const _kGuestBannerDismissed = 'pref_guest_banner_dismissed';
  static const _kSessionMode = 'pref_session_mode'; // guest | cloud
  static const _kThemeMode = 'pref_theme_mode'; // system | light | dark
  static const _kCourseCatalogRevisionAck = 'pref_course_catalog_revision_ack';
  static const _kRustoreReviewPrompted = 'pref_rustore_review_prompted';

  static Future<PreferencesService> create() async {
    final p = await SharedPreferences.getInstance();
    return PreferencesService._(p);
  }

  String get locale => _p.getString(_kLocale) ?? 'ru';

  Future<void> setLocale(String value) => _p.setString(_kLocale, value);

  bool get useCyrillic => _p.getBool(_kCyrillic) ?? false;

  Future<void> setUseCyrillic(bool value) => _p.setBool(_kCyrillic, value);

  bool get onboardingComplete => _p.getBool(_kOnboarding) ?? false;

  Future<void> setOnboardingComplete(bool value) =>
      _p.setBool(_kOnboarding, value);

  bool get guestBannerDismissed =>
      _p.getBool(_kGuestBannerDismissed) ?? false;

  Future<void> setGuestBannerDismissed(bool value) =>
      _p.setBool(_kGuestBannerDismissed, value);

  /// `guest` — только локально (Hive). `cloud` — аккаунт Supabase.
  String get sessionModeRaw => _p.getString(_kSessionMode) ?? 'guest';

  Future<void> setSessionModeRaw(String value) =>
      _p.setString(_kSessionMode, value);

  /// `system` | `light` | `dark`
  String get themeModeRaw => _p.getString(_kThemeMode) ?? 'system';

  Future<void> setThemeModeRaw(String value) =>
      _p.setString(_kThemeMode, value);

  /// Последняя известная ревизия каталога курсов (синхронизирована с загруженными данными).
  int? get courseCatalogRevisionAck {
    if (!_p.containsKey(_kCourseCatalogRevisionAck)) return null;
    return _p.getInt(_kCourseCatalogRevisionAck);
  }

  Future<void> setCourseCatalogRevisionAck(int value) =>
      _p.setInt(_kCourseCatalogRevisionAck, value);

  bool get rustoreReviewPrompted =>
      _p.getBool(_kRustoreReviewPrompted) ?? false;

  Future<void> setRustoreReviewPrompted(bool value) =>
      _p.setBool(_kRustoreReviewPrompted, value);
}
