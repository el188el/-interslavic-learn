import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/adaptive_body.dart';
import '../widgets/app_chrome_background.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  Future<List<_LeaderEntry>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<List<_LeaderEntry>> _load() async {
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
          final rows = <_LeaderEntry>[];
          final myId = client.auth.currentUser?.id;
          for (final e in list) {
            final m = Map<String, dynamic>.from(e as Map);
            final uid = m['user_id'] as String?;
            rows.add(_LeaderEntry(
              name: m['display_name'] as String? ?? '?',
              xp: (m['total_xp'] as num?)?.toInt() ?? 0,
              streak: (m['current_streak'] as num?)?.toInt() ?? 0,
              isCurrentUser: myId != null && uid == myId,
            ));
          }
          if (rows.isNotEmpty) return rows;
        }
      } catch (_) {
        /* fallback ниже */
      }
    }

    const npc = [
      _LeaderEntry(name: 'Anya', xp: 2450, streak: 14),
      _LeaderEntry(name: 'Marek', xp: 2100, streak: 21),
      _LeaderEntry(name: 'Ivan', xp: 1800, streak: 7),
      _LeaderEntry(name: 'Katarina', xp: 1650, streak: 10),
      _LeaderEntry(name: 'Boris', xp: 1200, streak: 5),
    ];
    final userEntry = _LeaderEntry(
      name: progress.displayName,
      xp: progress.totalXp,
      streak: progress.currentStreak,
      isCurrentUser: true,
    );
    final merged = [...npc, userEntry];
    merged.sort((a, b) => b.xp.compareTo(a.xp));
    return merged;
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isRu = locale == 'ru';
    final mode = ref.watch(sessionModeProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(isRu ? 'Рейтинг' : 'Leaderboard'),
      ),
      body: AppChromeBackground(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (mode == SessionMode.guest)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              color: DuoColors.warning.withValues(alpha: 0.2),
              child: Text(
                isRu
                    ? 'Режим гостя: таблица учебная. Войдите по email для глобального рейтинга.'
                    : 'Guest mode: demo board. Sign in with email for the global leaderboard.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          Expanded(
            child: AdaptiveBody(
              child: FutureBuilder<List<_LeaderEntry>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final sortedBoard = snap.data ?? [];
                if (sortedBoard.isEmpty) {
                  return Center(
                    child: Text(isRu ? 'Нет данных' : 'No data'),
                  );
                }
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      color: DuoColors.primaryGreen.withValues(alpha: 0.12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (sortedBoard.length > 1)
                            _PodiumItem(
                              entry: sortedBoard[1],
                              rank: 2,
                              height: 80,
                              color: Colors.grey.shade400,
                            ),
                          if (sortedBoard.isNotEmpty)
                            _PodiumItem(
                              entry: sortedBoard[0],
                              rank: 1,
                              height: 100,
                              color: Colors.amber,
                            ),
                          if (sortedBoard.length > 2)
                            _PodiumItem(
                              entry: sortedBoard[2],
                              rank: 3,
                              height: 60,
                              color: Colors.brown.shade300,
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: sortedBoard.length,
                        itemBuilder: (context, index) {
                          final entry = sortedBoard[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: index < 3
                                    ? [
                                        Colors.amber,
                                        Colors.grey.shade400,
                                        Colors.brown.shade300
                                      ][index]
                                    : Colors.grey.shade200,
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        index < 3 ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                              title: Text(
                                entry.isCurrentUser
                                    ? '${entry.name} ${isRu ? '(Вы)' : '(You)'}'
                                    : entry.name,
                                style: TextStyle(
                                  fontWeight: entry.isCurrentUser
                                      ? FontWeight.bold
                                      : null,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.local_fire_department,
                                    size: 16,
                                    color: entry.streak > 0
                                        ? Colors.deepOrange
                                        : Colors.grey,
                                  ),
                                  Text('${entry.streak}  '),
                                  const Icon(Icons.star,
                                      size: 16, color: Colors.amber),
                                  Text(
                                    ' ${entry.xp}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _LeaderEntry {
  final String name;
  final int xp;
  final int streak;
  final bool isCurrentUser;

  const _LeaderEntry({
    required this.name,
    required this.xp,
    required this.streak,
    this.isCurrentUser = false,
  });
}

class _PodiumItem extends StatelessWidget {
  final _LeaderEntry entry;
  final int rank;
  final double height;
  final Color color;

  const _PodiumItem({
    required this.entry,
    required this.rank,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: rank == 1 ? 28 : 22,
          backgroundColor: color,
          child: Text(
            entry.name.isNotEmpty ? entry.name[0] : '?',
            style: TextStyle(
              fontSize: rank == 1 ? 22 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          entry.name,
          style: TextStyle(
            fontWeight: entry.isCurrentUser ? FontWeight.bold : null,
            fontSize: 12,
          ),
        ),
        Text(
          '${entry.xp} XP',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Container(
          width: 60,
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.7),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
