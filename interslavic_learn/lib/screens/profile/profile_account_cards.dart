import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../errors/app_error_codes.dart';
import '../../providers/app_providers.dart';
import '../../services/supabase_service.dart';
import '../auth/email_auth_screen.dart';
import '../profile_account_dialogs.dart';
import 'profile_sign_out.dart';

class ProfileAccountCards extends ConsumerWidget {
  const ProfileAccountCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final progress = ref.watch(userProgressProvider);
    final sessionMode = ref.watch(sessionModeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        if (sessionMode == SessionMode.guest) ...[
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(Icons.cloud_upload_outlined,
                  color: Colors.blue),
              title: Text(
                locale == 'ru'
                    ? 'Привязать аккаунт (email)'
                    : 'Link account (email)',
              ),
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
                        formatUserError(
                          isRu: locale == 'ru',
                          code: AppErrorCodes.linkAccountBuildMissingKeys,
                          headlineRu:
                              'В сборке не заданы ключи Supabase (dart-define или CI-секреты).',
                          headlineEn:
                              'Supabase keys missing in this build (dart-define or CI secrets).',
                        ),
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
        ],
        if (sessionMode == SessionMode.cloud) ...[
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: Icon(Icons.logout,
                  color: Theme.of(context).colorScheme.error),
              title: Text(locale == 'ru' ? 'Выйти' : 'Sign out'),
              subtitle: Text(
                locale == 'ru'
                    ? 'Выйти из аккаунта. Прогресс останется на этом устройстве; облачная синхронизация отключится.'
                    : 'Sign out. Progress stays on this device; cloud sync will be off.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => profileSignOut(context, ref),
            ),
          ),
        ],
      ],
    );
  }
}
