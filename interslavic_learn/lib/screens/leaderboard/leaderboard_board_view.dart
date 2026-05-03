import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'leaderboard_entry.dart';
import 'leaderboard_podium.dart';
import 'leaderboard_ranked_list.dart';

class LeaderboardBoardView extends StatelessWidget {
  const LeaderboardBoardView({
    super.key,
    required this.sortedBoard,
    required this.isRu,
  });

  final List<LeaderboardEntry> sortedBoard;
  final bool isRu;

  @override
  Widget build(BuildContext context) {
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
                LeaderboardPodiumItem(
                  entry: sortedBoard[1],
                  rank: 2,
                  height: 80,
                  color: Colors.grey.shade400,
                ),
              if (sortedBoard.isNotEmpty)
                LeaderboardPodiumItem(
                  entry: sortedBoard[0],
                  rank: 1,
                  height: 100,
                  color: Colors.amber,
                ),
              if (sortedBoard.length > 2)
                LeaderboardPodiumItem(
                  entry: sortedBoard[2],
                  rank: 3,
                  height: 60,
                  color: Colors.brown.shade300,
                ),
            ],
          ),
        ),
        Expanded(
          child: LeaderboardRankedList(
            sortedBoard: sortedBoard,
            isRu: isRu,
          ),
        ),
      ],
    );
  }
}
