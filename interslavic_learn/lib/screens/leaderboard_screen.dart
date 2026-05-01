import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final progress = ref.watch(userProgressProvider);

    // Mock leaderboard data (to be synced via backend in production)
    final leaderboard = [
      _LeaderEntry(name: 'Anya', xp: 2450, streak: 14),
      _LeaderEntry(name: 'Marek', xp: 2100, streak: 21),
      _LeaderEntry(name: 'Ivan', xp: 1800, streak: 7),
      _LeaderEntry(name: 'Katarina', xp: 1650, streak: 10),
      _LeaderEntry(name: 'Boris', xp: 1200, streak: 5),
      _LeaderEntry(name: 'Milena', xp: 980, streak: 3),
      _LeaderEntry(name: 'Dmitrij', xp: 850, streak: 8),
      _LeaderEntry(name: 'Jana', xp: 720, streak: 2),
      _LeaderEntry(name: 'Petr', xp: 600, streak: 4),
      _LeaderEntry(name: 'Zorka', xp: 450, streak: 1),
    ];

    // Insert current user into the leaderboard
    final userEntry = _LeaderEntry(
      name: progress.displayName,
      xp: progress.totalXp,
      streak: progress.currentStreak,
      isCurrentUser: true,
    );

    final sortedBoard = [...leaderboard, userEntry]
      ..sort((a, b) => b.xp.compareTo(a.xp));

    return Scaffold(
      appBar: AppBar(
        title: Text(locale == 'ru' ? 'Глобальный рейтинг' : 'Global Leaderboard'),
      ),
      body: Column(
        children: [
          // Top 3 podium
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
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

          // Full list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: sortedBoard.length,
              itemBuilder: (context, index) {
                final entry = sortedBoard[index];
                return Card(
                  color: entry.isCurrentUser
                      ? Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withValues(alpha: 0.5)
                      : null,
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: index < 3
                          ? [Colors.amber, Colors.grey.shade400, Colors.brown.shade300][index]
                          : Colors.grey.shade200,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: index < 3 ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    title: Text(
                      entry.isCurrentUser
                          ? '${entry.name} ${locale == 'ru' ? '(Вы)' : '(You)'}'
                          : entry.name,
                      style: TextStyle(
                        fontWeight:
                            entry.isCurrentUser ? FontWeight.bold : null,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_fire_department,
                            size: 16,
                            color: entry.streak > 0
                                ? Colors.deepOrange
                                : Colors.grey),
                        Text('${entry.streak}  '),
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        Text(' ${entry.xp}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
        Text('${entry.xp} XP',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
