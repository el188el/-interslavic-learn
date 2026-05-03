import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../legal/privacy_policy_texts.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_chrome_background.dart';

/// Политика конфиденциальности — текст синхронизирован с `privacy_policy_texts.dart`.
class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final cs = Theme.of(context).colorScheme;
    final sections = PrivacyPolicyTexts.sections(locale);

    return Scaffold(
      appBar: AppBar(
        title: Text(PrivacyPolicyTexts.title(locale)),
      ),
      body: AppChromeBackground(
        child: SelectionArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              Text(
                locale == 'ru'
                    ? 'Последнее обновление: ${PrivacyPolicyTexts.lastUpdated}'
                    : 'Last updated: ${PrivacyPolicyTexts.lastUpdated}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              for (final s in sections) ...[
                Text(
                  s.heading,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  s.body,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.45,
                      ),
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
