import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../services/guest_session.dart';
import '../services/supabase_service.dart';
import 'auth/email_auth_screen.dart';
import 'profile_account_dialogs.dart';
import '../config/monetization_config.dart';
import '../widgets/adaptive_body.dart';
import '../widgets/app_chrome_background.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final progress = ref.watch(userProgressProvider);
    final sessionMode = ref.watch(sessionModeProvider);

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

          const SizedBox(height: 16),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.badge_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    locale == 'ru' ? 'Изменить имя' : 'Change display name',
                  ),
                  subtitle: Text(progress.displayName),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showDisplayNameEditor(context, ref),
                ),
                if (sessionMode == SessionMode.cloud && isSupabaseConfigured)
                  ListTile(
                    leading: Icon(
                      Icons.password_outlined,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    title: Text(
                      locale == 'ru' ? 'Сменить пароль' : 'Change password',
                    ),
                    subtitle: Text(
                      locale == 'ru'
                          ? 'Новый пароль для входа по email'
                          : 'New password for email login',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => showChangePasswordDialog(context, ref),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          if (sessionMode == SessionMode.guest)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(Icons.cloud_upload_outlined,
                    color: Colors.blue),
                title: Text(locale == 'ru'
                    ? 'Привязать аккаунт (email)'
                    : 'Link account (email)'),
                subtitle: Text(
                  locale == 'ru'
                      ? 'Сохраните прогресс в облаке и участвуйте в глобальном рейтинге.'
                      : 'Save progress to the cloud and join the global leaderboard.',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  if (!isSupabaseConfigured) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          locale == 'ru'
                              ? 'В этой сборке не заданы SUPABASE_URL и SUPABASE_ANON_KEY. Добавьте их через --dart-define или dart_defines.json (см. interslavic_learn/dart_defines.example.json).'
                              : 'This build has no SUPABASE_URL / SUPABASE_ANON_KEY. Add them via --dart-define or dart_defines.json (see interslavic_learn/dart_defines.example.json).',
                        ),
                      ),
                    );
                    return;
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const EmailAuthScreen(),
                    ),
                  );
                },
              ),
            ),

          if (sessionMode == SessionMode.guest)
            const SizedBox(height: 16),

          if (sessionMode == SessionMode.cloud)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: Icon(Icons.logout,
                    color: Theme.of(context).colorScheme.error),
                title: Text(
                    locale == 'ru' ? 'Выйти' : 'Sign out'),
                subtitle: Text(
                  locale == 'ru'
                      ? 'Выйти из аккаунта. Прогресс останется на этом устройстве; облачная синхронизация отключится.'
                      : 'Sign out. Progress stays on this device; cloud sync will be off.',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _signOut(context, ref),
              ),
            ),

          if (sessionMode == SessionMode.cloud)
            const SizedBox(height: 16),

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
                    progress.isPremium
                        ? (locale == 'ru'
                            ? 'Премиум активен — реклама в приложении не показывается.'
                            : 'Premium is active — ads are not shown in the app.')
                        : (locale == 'ru'
                            ? 'Все уроки бесплатны. Сейчас премиум — это отключение рекламы: единоразово ${MonetizationConfig.premiumPriceRub} ₽.\n'
                                'Оплата появится в RuStore и при установке APK со страницы приложения. Расширенная статистика и оформление профиля — позже.'
                            : 'All lessons are free. Premium currently means ad-free: a one-time ${MonetizationConfig.premiumPriceRub} ₽ purchase.\n'
                                'Payment will be available via RuStore and when installing the APK from the app page. More stats and profile styling — later.'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (!progress.isPremium) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(locale == 'ru'
                                  ? 'Оплата премиума будет в RuStore и на странице загрузки APK.'
                                  : 'Premium purchase will be available in RuStore and on the APK download page.'),
                            ),
                          );
                        },
                        child: Text(locale == 'ru'
                            ? 'Оформить — ${MonetizationConfig.premiumPriceRub} ₽'
                            : 'Get Premium — ${MonetizationConfig.premiumPriceRub} ₽'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          ],
          ),
        ),
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

Future<void> _signOut(BuildContext context, WidgetRef ref) async {
  final locale = ref.read(localeProvider);
  final isRu = locale == 'ru';

  if (!isSupabaseConfigured || supabaseOrNull == null) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isRu
              ? 'Supabase не настроен в этой сборке.'
              : 'Supabase is not configured in this build.',
        ),
      ),
    );
    return;
  }

  try {
    await supabaseOrNull!.auth.signOut();
    await ref.read(preferencesServiceProvider).setSessionModeRaw('guest');
    ref.read(sessionModeProvider.notifier).state = SessionMode.guest;

    final progressService = ref.read(progressServiceProvider);
    final local = progressService.getProgress();
    local.supabaseUserId = '';
    await local.save();

    await GuestSession.ensure(progressService);
    ref.read(userProgressProvider.notifier).refresh();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isRu ? 'Вы вышли из аккаунта' : 'Signed out',
        ),
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$e')),
    );
  }
}
