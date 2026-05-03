import 'package:flutter/material.dart';

import 'leaderboard_entry.dart';

class LeaderboardPodiumItem extends StatelessWidget {
  const LeaderboardPodiumItem({
    super.key,
    required this.entry,
    required this.rank,
    required this.height,
    required this.color,
  });

  final LeaderboardEntry entry;
  final int rank;
  final double height;
  final Color color;

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
