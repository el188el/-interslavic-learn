import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user_progress.dart';
import '../../providers/app_providers.dart';
import '../../widgets/adaptive_body.dart';
import '../../widgets/app_chrome_background.dart';
import 'leaderboard_board_view.dart';
import 'leaderboard_data.dart';
import 'leaderboard_entry.dart';
import 'leaderboard_guest_banner.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  Future<List<LeaderboardEntry>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= loadLeaderboard(ref);
  }

  void _reloadBoard() {
    setState(() {
      _future = loadLeaderboard(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<UserProgress>(userProgressProvider, (prev, next) {
      if (prev != null &&
          prev.totalXp == next.totalXp &&
          prev.currentStreak == next.currentStreak &&
          prev.displayName == next.displayName) {
        return;
      }
      _reloadBoard();
    });
    final locale = ref.watch(localeProvider);
    final isRu = locale == 'ru';
    ref.watch(userProgressProvider);
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
              LeaderboardGuestBanner(isRu: isRu),
            Expanded(
              child: AdaptiveBody(
                child: FutureBuilder<List<LeaderboardEntry>>(
                  future: _future,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final sortedBoard = snap.data ?? [];
                    return LeaderboardBoardView(
                      sortedBoard: sortedBoard,
                      isRu: isRu,
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
