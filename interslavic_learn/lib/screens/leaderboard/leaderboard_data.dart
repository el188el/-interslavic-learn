import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../../services/supabase_service.dart';
import 'leaderboard_entry.dart';

/// Сортировка по убыванию XP (как демо-таблица и финальный список).
void sortLeaderboardByXpDesc(List<LeaderboardEntry> entries) {
  entries.sort((a, b) => b.xp.compareTo(a.xp));
}

Future<List<LeaderboardEntry>> loadLeaderboard(WidgetRef ref) async {
  final progress = ref.read(userProgressProvider);
  final mode = ref.read(sessionModeProvider);

  if (mode == SessionMode.cloud && isSupabaseConfigured) {
    try {
      final client = supabaseOrNull;
      if (client != null) {
        final raw = await client.rpc(
          'leaderboard_top',
          params: {'row_limit': 100},
        );
        final list = raw as List<dynamic>? ?? [];
        final rows = <LeaderboardEntry>[];
        final myId = client.auth.currentUser?.id;
        for (final e in list) {
          final m = Map<String, dynamic>.from(e as Map);
          final uid = m['user_id'] as String?;
          rows.add(
            LeaderboardEntry(
              name: m['display_name'] as String? ?? '?',
              xp: (m['total_xp'] as num?)?.toInt() ?? 0,
              streak: (m['current_streak'] as num?)?.toInt() ?? 0,
              isCurrentUser: myId != null && uid == myId,
            ),
          );
        }
        if (rows.isNotEmpty) return rows;
      }
    } catch (_) {
      /* fallback ниже */
    }
  }

  final userEntry = LeaderboardEntry(
    name: progress.displayName,
    xp: progress.totalXp,
    streak: progress.currentStreak,
    isCurrentUser: true,
  );

  if (mode == SessionMode.guest) {
    return [userEntry];
  }

  const npcNames = ['Anya', 'Marek', 'Ivan', 'Katarina', 'Boris'];
  const npcStreaks = [14, 21, 7, 10, 5];
  final ux = progress.totalXp;
  const deltas = [120, 85, 55, 25, -10];
  final npc = List<LeaderboardEntry>.generate(npcNames.length, (i) {
    return LeaderboardEntry(
      name: npcNames[i],
      xp: (ux + deltas[i]).clamp(0, 999999999),
      streak: npcStreaks[i],
      isCurrentUser: false,
    );
  });
  final merged = [...npc, userEntry];
  sortLeaderboardByXpDesc(merged);
  return merged;
}
