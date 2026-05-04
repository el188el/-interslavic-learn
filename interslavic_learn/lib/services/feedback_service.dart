import 'package:package_info_plus/package_info_plus.dart';

import 'supabase_service.dart';

enum FeedbackScreenKind { theory, exercise, settings }

class FeedbackPayload {
  FeedbackPayload({
    required this.screen,
    required this.message,
    required this.displayName,
    this.lessonId,
    this.categoryId,
    this.userId,
    this.guestEmail,
    this.appVersion,
  });

  final FeedbackScreenKind screen;
  final String message;
  final String displayName;
  final String? lessonId;
  final String? categoryId;
  final String? userId;
  final String? guestEmail;
  final String? appVersion;

  String get screenValue {
    switch (screen) {
      case FeedbackScreenKind.theory:
        return 'theory';
      case FeedbackScreenKind.exercise:
        return 'exercise';
      case FeedbackScreenKind.settings:
        return 'settings';
    }
  }
}

class FeedbackService {
  static Future<String?> appVersionString() async {
    try {
      final p = await PackageInfo.fromPlatform();
      return '${p.version}+${p.buildNumber}';
    } catch (_) {
      return null;
    }
  }

  static Future<void> submit(FeedbackPayload p) async {
    final c = supabaseOrNull;
    if (c == null) {
      throw StateError('Supabase is not configured');
    }
    final row = <String, dynamic>{
      'message': p.message.trim(),
      'display_name': p.displayName.trim(),
      'screen': p.screenValue,
      'lesson_id': p.lessonId,
      'category_id': p.categoryId,
      'app_version': p.appVersion,
    };
    if (p.userId != null) {
      row['user_id'] = p.userId;
      row['guest_email'] = null;
    } else {
      row['user_id'] = null;
      row['guest_email'] = (p.guestEmail == null || p.guestEmail!.trim().isEmpty)
          ? null
          : p.guestEmail!.trim();
    }
    await c.from('app_feedback').insert(row);
  }
}
