import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class LeaderboardGuestBanner extends StatelessWidget {
  const LeaderboardGuestBanner({super.key, required this.isRu});

  final bool isRu;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: DuoColors.warning.withValues(alpha: 0.2),
      child: Text(
        isRu
            ? 'Режим гостя: таблица учебная. Войдите по email для глобального рейтинга.'
            : 'Guest mode: demo board. Sign in with email for the global leaderboard.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
