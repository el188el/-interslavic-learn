import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_progress.dart';
import 'progress_service.dart';

/// Local-only guest display name: `gost_<id>`. Data is not synced; lost on uninstall.
class GuestSession {
  GuestSession._(this.displayName);

  static const _prefix = 'gost_';
  static const _kGuestId = 'guest_local_id';

  final String displayName;

  static Future<GuestSession> ensure(ProgressService progress) async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString(_kGuestId);
    id ??= const Uuid().v4().replaceAll('-', '').substring(0, 10);
    await prefs.setString(_kGuestId, id);

    final name = '$_prefix$id';
    final UserProgress p = progress.getProgress();
    // Не затираем имя, которое пользователь задал вручную (не «Ученик» и не пусто).
    final needsDefaultGuestName =
        p.displayName.isEmpty || p.displayName == 'Ученик';
    if (needsDefaultGuestName) {
      p.displayName = name;
      await p.save();
    }

    return GuestSession._(p.displayName);
  }
}
