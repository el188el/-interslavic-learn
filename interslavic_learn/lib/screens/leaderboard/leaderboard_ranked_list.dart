import 'package:flutter/material.dart';

import 'leaderboard_entry.dart';

class LeaderboardRankedList extends StatelessWidget {
  const LeaderboardRankedList({
    super.key,
    required this.sortedBoard,
    required this.isRu,
  });

  final List<LeaderboardEntry> sortedBoard;
  final bool isRu;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
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
                  color: index < 3 ? Colors.white : Colors.black,
                ),
              ),
            ),
            title: Text(
              entry.isCurrentUser
                  ? '${entry.name} ${isRu ? '(Вы)' : '(You)'}'
                  : entry.name,
              style: TextStyle(
                fontWeight:
                    entry.isCurrentUser ? FontWeight.bold : null,
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
                const Icon(Icons.star, size: 16, color: Colors.amber),
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
    );
  }
}
