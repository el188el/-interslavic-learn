import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Числовые коды ошибок для поддержки и логов. Сообщения в UI — через [formatUserError].
///
/// Справка по кодам (ищите в коде `AppErrorCodes.`):
/// **101** — Supabase не вшит в сборку (вход по email).
/// **102** — пустой email или короткий пароль.
/// **103** — вход: неверные email/пароль.
/// **104** — регистрация: неверные email/пароль.
/// **105** — email не подтверждён.
/// **106** — аккаунт уже зарегистрирован.
/// **107** — слишком много попыток.
/// **108** — слабый пароль (правила сервера).
/// **109** — прочая ошибка ответа авторизации (не попала под шаблоны выше).
/// **120–124** — сеть при входе/регистрации.
/// **125** — синхронизация с облаком после входа.
/// **130** — Supabase не настроен (выход).
/// **131–133** — ошибка выхода (сеть / сервер / прочее).
/// **140–145** — смена пароля (Supabase / валидация / сеть / прочее).
/// **150** — привязка аккаунта: нет ключей в сборке.
/// **161–162** — не открылась ссылка или почта в настройках.
abstract final class AppErrorCodes {
  // --- Вход / регистрация (email) ---
  static const int authSupabaseNotConfigured = 101;
  static const int authInvalidEmailOrPassword = 102;
  static const int authInvalidCredentialsSignIn = 103;
  static const int authInvalidCredentialsRegister = 104;
  static const int authEmailNotConfirmed = 105;
  static const int authUserAlreadyRegistered = 106;
  static const int authRateLimited = 107;
  static const int authWeakPassword = 108;
  static const int authServerMessage = 109;

  // --- Сеть ---
  static const int networkSocket = 120;
  static const int networkClient = 121;
  static const int networkHostLookup = 122;
  static const int networkGeneric = 123;
  static const int authNetworkUnknown = 124;

  // --- Синхронизация после входа ---
  static const int syncAfterLoginFailed = 125;

  // --- Профиль / выход ---
  static const int profileSupabaseNotConfigured = 130;
  static const int profileSignOutNetwork = 131;
  static const int profileSignOutServer = 132;
  static const int profileSignOutUnknown = 133;

  // --- Смена пароля ---
  static const int passwordSupabaseNotConfigured = 140;
  static const int passwordTooShort = 141;
  static const int passwordMismatch = 142;
  static const int passwordUpdateFailed = 143;
  static const int passwordUnknown = 144;
  static const int passwordChangeNetwork = 145;

  // --- Привязка аккаунта (плитка в профиле) ---
  static const int linkAccountBuildMissingKeys = 150;

  // --- Настройки (ссылки) ---
  static const int settingsOpenUrlFailed = 161;
  static const int settingsOpenMailFailed = 162;
}

/// Текст для пользователя: заголовок + «Код ошибки: NNN».
String formatUserError({
  required bool isRu,
  required int code,
  required String headlineRu,
  required String headlineEn,
}) {
  final h = isRu ? headlineRu : headlineEn;
  return isRu ? '$h Код ошибки: $code' : '$h Error code: $code';
}

/// Разбор [AuthException] → код + заголовки (раздельно для входа и регистрации где уместно).
(int code, String headlineRu, String headlineEn) mapAuthException(
  AuthException e, {
  required bool isRegister,
}) {
  final msg = e.message.toLowerCase();
  final sc = (e.statusCode?.toString() ?? '').toLowerCase();

  bool has(String a) => msg.contains(a) || sc.contains(a);

  if (has('email not confirmed') || has('not confirmed')) {
    return (
      AppErrorCodes.authEmailNotConfirmed,
      'Ошибка входа: email не подтверждён.',
      'Sign-in error: email not confirmed.',
    );
  }
  if (has('already registered') ||
      has('user already') ||
      has('already been registered')) {
    return (
      AppErrorCodes.authUserAlreadyRegistered,
      'Ошибка регистрации: такой аккаунт уже есть.',
      'Registration error: account already exists.',
    );
  }
  if (has('rate limit') || has('too many') || has('over_request')) {
    return (
      AppErrorCodes.authRateLimited,
      isRegister
          ? 'Ошибка регистрации: слишком много попыток.'
          : 'Ошибка входа: слишком много попыток.',
      isRegister
          ? 'Registration error: too many attempts.'
          : 'Sign-in error: too many attempts.',
    );
  }
  if (has('password') &&
      (has('weak') || has('least') || has('characters'))) {
    return (
      AppErrorCodes.authWeakPassword,
      'Ошибка регистрации: пароль не подходит по правилам сервера.',
      'Registration error: password does not meet server rules.',
    );
  }
  if (has('invalid') &&
      (has('credential') || has('login') || has('password') || has('email'))) {
    return (
      isRegister
          ? AppErrorCodes.authInvalidCredentialsRegister
          : AppErrorCodes.authInvalidCredentialsSignIn,
      isRegister
          ? 'Ошибка регистрации: неверные email или пароль.'
          : 'Ошибка входа: неверные email или пароль.',
      isRegister
          ? 'Registration error: invalid email or password.'
          : 'Sign-in error: invalid email or password.',
    );
  }

  if (kDebugMode) {
    debugPrint('AuthException unmapped: status=${e.statusCode} msg=${e.message}');
  }
  return (
    AppErrorCodes.authServerMessage,
    'Ошибка сервера авторизации.',
    'Authorization server error.',
  );
}

/// Сеть и прочие исключения при входе/регистрации (не [AuthException]).
(int code, String headlineRu, String headlineEn) mapAuthFlowThrowable(
  Object e, {
  required bool isRegister,
}) {
  if (kDebugMode) {
    debugPrint('mapAuthFlowThrowable: $e');
  }
  if (e is SocketException) {
    return (
      AppErrorCodes.networkSocket,
      isRegister
          ? 'Ошибка регистрации: нет соединения с сетью.'
          : 'Ошибка входа: нет соединения с сетью.',
      isRegister
          ? 'Registration error: no network connection.'
          : 'Sign-in error: no network connection.',
    );
  }
  if (e is http.ClientException) {
    return (
      AppErrorCodes.networkClient,
      isRegister
          ? 'Ошибка регистрации: не удалось связаться с сервером.'
          : 'Ошибка входа: не удалось связаться с сервером.',
      isRegister
          ? 'Registration error: could not reach the server.'
          : 'Sign-in error: could not reach the server.',
    );
  }
  if (e is Exception) {
    final s = e.toString();
    if (s.startsWith('Exception: ')) {
      return (
        AppErrorCodes.authInvalidEmailOrPassword,
        s.substring('Exception: '.length),
        s.substring('Exception: '.length),
      );
    }
  }
  final raw = e.toString();
  if (raw.contains('Failed host lookup') || raw.contains('SocketException')) {
    return (
      AppErrorCodes.networkHostLookup,
      isRegister
          ? 'Ошибка регистрации: не найден адрес сервера (DNS/сеть).'
          : 'Ошибка входа: не найден адрес сервера (DNS/сеть).',
      isRegister
          ? 'Registration error: server address not found (DNS/network).'
          : 'Sign-in error: server address not found (DNS/network).',
    );
  }
  if (raw.contains('HandshakeException') ||
      raw.contains('Connection refused') ||
      raw.contains('Connection reset')) {
    return (
      AppErrorCodes.networkGeneric,
      isRegister
          ? 'Ошибка регистрации: сбой сети.'
          : 'Ошибка входа: сбой сети.',
      isRegister
          ? 'Registration error: network failure.'
          : 'Sign-in error: network failure.',
    );
  }
  return (
    AppErrorCodes.authNetworkUnknown,
    isRegister
        ? 'Ошибка регистрации: неизвестная ошибка.'
        : 'Ошибка входа: неизвестная ошибка.',
    isRegister
        ? 'Registration error: unknown error.'
        : 'Sign-in error: unknown error.',
  );
}

(int code, String headlineRu, String headlineEn) mapSignOutError(Object e) {
  if (kDebugMode) {
    debugPrint('mapSignOutError: $e');
  }
  if (e is AuthException) {
    return (
      AppErrorCodes.profileSignOutServer,
      'Ошибка выхода: ответ сервера.',
      'Sign-out error: server response.',
    );
  }
  if (e is SocketException || e is http.ClientException) {
    return (
      AppErrorCodes.profileSignOutNetwork,
      'Ошибка выхода: нет соединения с сетью.',
      'Sign-out error: no network connection.',
    );
  }
  final raw = e.toString();
  if (raw.contains('SocketException') ||
      raw.contains('Failed host lookup') ||
      raw.contains('ClientException')) {
    return (
      AppErrorCodes.profileSignOutNetwork,
      'Ошибка выхода: не удалось связаться с сервером.',
      'Sign-out error: could not reach the server.',
    );
  }
  return (
    AppErrorCodes.profileSignOutUnknown,
    'Ошибка выхода из аккаунта.',
    'Sign-out error.',
  );
}

(int code, String headlineRu, String headlineEn) mapPasswordChangeError(
  Object e,
) {
  if (kDebugMode) {
    debugPrint('mapPasswordChangeError: $e');
  }
  if (e is AuthException) {
    return (
      AppErrorCodes.passwordUpdateFailed,
      'Ошибка смены пароля.',
      'Password change error.',
    );
  }
  if (e is SocketException || e is http.ClientException) {
    return (
      AppErrorCodes.passwordChangeNetwork,
      'Ошибка смены пароля: нет сети.',
      'Password change error: no network.',
    );
  }
  final raw = e.toString();
  if (raw.contains('SocketException') ||
      raw.contains('Failed host lookup') ||
      raw.contains('ClientException')) {
    return (
      AppErrorCodes.passwordChangeNetwork,
      'Ошибка смены пароля: сеть.',
      'Password change error: network.',
    );
  }
  return (
    AppErrorCodes.passwordUnknown,
    'Ошибка смены пароля: неизвестная ошибка.',
    'Password change error: unknown.',
  );
}
