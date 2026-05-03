import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../errors/app_error_codes.dart'
    show AppErrorCodes, formatUserError, mapSignOutError;
import '../../providers/app_providers.dart';
import '../../services/guest_session.dart';
import '../../services/supabase_service.dart';

Future<void> profileSignOut(BuildContext context, WidgetRef ref) async {
  final locale = ref.read(localeProvider);
  final isRu = locale == 'ru';

  if (!isSupabaseConfigured || supabaseOrNull == null) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          formatUserError(
            isRu: isRu,
            code: AppErrorCodes.profileSupabaseNotConfigured,
            headlineRu: 'Supabase не настроен в этой сборке.',
            headlineEn: 'Supabase is not configured in this build.',
          ),
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
        content: Text(isRu ? 'Вы вышли из аккаунта' : 'Signed out'),
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    final m = mapSignOutError(e);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          formatUserError(
            isRu: isRu,
            code: m.$1,
            headlineRu: m.$2,
            headlineEn: m.$3,
          ),
        ),
      ),
    );
  }
}
