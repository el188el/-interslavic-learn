import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../../widgets/adaptive_body.dart';
import '../../widgets/app_chrome_background.dart';
import 'profile_account_cards.dart';
import 'profile_header.dart';
import 'profile_premium_card.dart';
import 'profile_stats_row.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final progress = ref.watch(userProgressProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(locale == 'ru' ? 'Профиль' : 'Profile'),
      ),
      body: AppChromeBackground(
        child: AdaptiveBody(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ProfileHeader(progress: progress),
              const SizedBox(height: 16),
              const ProfileAccountCards(),
              const SizedBox(height: 24),
              ProfileStatsRow(
                items: [
                  ProfileStatItem(
                    icon: Icons.star,
                    color: Colors.amber,
                    value: '${progress.totalXp}',
                    label: 'XP',
                  ),
                  ProfileStatItem(
                    icon: Icons.local_fire_department,
                    color: Colors.deepOrange,
                    value: '${progress.currentStreak}',
                    label: locale == 'ru' ? 'Серия' : 'Streak',
                  ),
                  ProfileStatItem(
                    icon: Icons.emoji_events,
                    color: Colors.purple,
                    value: '${progress.bestStreak}',
                    label: locale == 'ru' ? 'Лучшая' : 'Best',
                  ),
                  ProfileStatItem(
                    icon: Icons.check_circle,
                    color: Colors.green,
                    value: '${progress.completedLessons.length}',
                    label: locale == 'ru' ? 'Уроков' : 'Lessons',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ProfilePremiumCard(progress: progress, locale: locale),
            ],
          ),
        ),
      ),
    );
  }
}
