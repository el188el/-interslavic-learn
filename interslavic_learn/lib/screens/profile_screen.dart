import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final progress = ref.watch(userProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(locale == 'ru' ? 'Профиль' : 'Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar + name
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        progress.displayName.isNotEmpty
                            ? progress.displayName[0].toUpperCase()
                            : 'У',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
                        ),
                      ),
                    ),
                    if (progress.isPremium)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.star,
                              color: Colors.white, size: 16),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  progress.displayName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Stats
          _StatsRow(
            items: [
              _StatItem(
                icon: Icons.star,
                color: Colors.amber,
                value: '${progress.totalXp}',
                label: 'XP',
              ),
              _StatItem(
                icon: Icons.local_fire_department,
                color: Colors.deepOrange,
                value: '${progress.currentStreak}',
                label: locale == 'ru' ? 'Серия' : 'Streak',
              ),
              _StatItem(
                icon: Icons.emoji_events,
                color: Colors.purple,
                value: '${progress.bestStreak}',
                label: locale == 'ru' ? 'Лучшая' : 'Best',
              ),
              _StatItem(
                icon: Icons.check_circle,
                color: Colors.green,
                value: '${progress.completedLessons.length}',
                label: locale == 'ru' ? 'Уроков' : 'Lessons',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Premium section
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.workspace_premium,
                          color: Colors.amber, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        locale == 'ru' ? 'Премиум' : 'Premium',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    locale == 'ru'
                        ? 'Все уроки бесплатны! Премиум включает:\n• Расширенную статистику\n• Косметические рамки профиля\n• Отключение рекламы'
                        : 'All lessons are free! Premium includes:\n• Advanced statistics\n• Cosmetic profile frames\n• Ad removal',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(locale == 'ru'
                                ? 'Премиум скоро будет доступен!'
                                : 'Premium coming soon!'),
                          ),
                        );
                      },
                      child: Text(locale == 'ru'
                          ? 'Узнать больше'
                          : 'Learn More'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final List<_StatItem> items;
  const _StatsRow({required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items
          .map((item) => Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        Icon(item.icon, color: item.color, size: 28),
                        const SizedBox(height: 4),
                        Text(
                          item.value,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: item.color,
                          ),
                        ),
                        Text(item.label,
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _StatItem {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  const _StatItem({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });
}
