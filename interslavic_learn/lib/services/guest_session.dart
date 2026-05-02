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
    final needsName =
        !p.displayName.startsWith(_prefix) || p.displayName == 'Ученик';
    if (needsName) {
      p.displayName = name;
      await p.save();
    }

    final shown =
        p.displayName.startsWith(_prefix) ? p.displayName : name;
    return GuestSession._(shown);
  }
}
