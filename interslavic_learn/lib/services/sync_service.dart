import '../models/user_progress.dart';
import 'progress_service.dart';
import 'supabase_service.dart';

/// Синхронизация локального Hive-прогресса с Supabase после входа по email.
class SyncService {
  SyncService(this._progress);

  final ProgressService _progress;

  Future<void> pushLocalProgressToCloud() async {
    final client = supabaseOrNull;
    if (client == null) return;

    final uid = client.auth.currentUser?.id;
    if (uid == null) return;

    final UserProgress local = _progress.getProgress();

    await client.from('user_progress').upsert({
      'user_id': uid,
      'total_xp': local.totalXp,
      'current_streak': local.currentStreak,
      'best_streak': local.bestStreak,
      'last_active_date': local.lastActiveDate.isEmpty
          ? null
          : local.lastActiveDate,
    }, onConflict: 'user_id');

    await client.from('profiles').update({
      'display_name': local.displayName,
    }).eq('id', uid);

    for (final lessonId in local.completedLessons) {
      final xp = local.lessonScores[lessonId] ?? 0;
      await client.from('lesson_completions').upsert({
        'user_id': uid,
        'lesson_id': lessonId,
        'score_xp': xp,
      }, onConflict: 'user_id,lesson_id');
    }

    local.supabaseUserId = uid;
    await local.save();
  }

  Future<void> pullCloudProgressToLocal() async {
    final client = supabaseOrNull;
    if (client == null) return;

    final uid = client.auth.currentUser?.id;
    if (uid == null) return;

    final row = await client
        .from('user_progress')
        .select()
        .eq('user_id', uid)
        .maybeSingle();

    if (row == null) return;

    final local = _progress.getProgress();
    local.totalXp = row['total_xp'] as int? ?? 0;
    local.currentStreak = row['current_streak'] as int? ?? 0;
    local.bestStreak = row['best_streak'] as int? ?? 0;

    final lad = row['last_active_date'];
    if (lad == null) {
      local.lastActiveDate = '';
    } else {
      final s = lad.toString();
      local.lastActiveDate = s.length >= 10 ? s.substring(0, 10) : s;
    }

    local.completedLessons.clear();
    local.lessonScores.clear();
    local.lessonCheckpoints.clear();

    final completions = await client
        .from('lesson_completions')
        .select('lesson_id, score_xp')
        .eq('user_id', uid);

    final list = completions as List<dynamic>? ?? [];
    for (final e in list) {
      final m = Map<String, dynamic>.from(e as Map);
      final lid = m['lesson_id'] as String;
      local.completedLessons.add(lid);
      local.lessonScores[lid] = m['score_xp'] as int? ?? 0;
    }

    final profile = await client
        .from('profiles')
        .select('display_name')
        .eq('id', uid)
        .maybeSingle();

    if (profile != null) {
      final dn = profile['display_name'] as String?;
      if (dn != null && dn.isNotEmpty) {
        local.displayName = dn;
      }
    }
    local.supabaseUserId = uid;
    await local.save();
  }

  /// После входа: если облако пустое — отправляем локальное; иначе берём более «жирный» прогресс.
  Future<void> mergeOnLogin() async {
    final client = supabaseOrNull;
    final uid = client?.auth.currentUser?.id;
    if (client == null || uid == null) return;

    final cloudProg =
        await client.from('user_progress').select().eq('user_id', uid).maybeSingle();
    if (cloudProg == null) {
      await pushLocalProgressToCloud();
      return;
    }

    final cloudXp = cloudProg['total_xp'] as int? ?? 0;
    final local = _progress.getProgress();
    if (local.totalXp >= cloudXp) {
      await pushLocalProgressToCloud();
    } else {
      await pullCloudProgressToLocal();
    }
  }
}
