import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/monetization_config.dart';
import '../providers/app_providers.dart';

/// Место под нижний рекламный баннер (над [NavigationBar]). При [UserProgress.isPremium] скрывается.
/// TODO: встроить виджет выбранной рекламной SDK вместо заглушки.
class AdBannerSlot extends ConsumerWidget {
  const AdBannerSlot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premium = ref.watch(userProgressProvider).isPremium;
    if (premium) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;

    return SizedBox(
      height: MonetizationConfig.adBannerHeightDp,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          border: Border(
            top: BorderSide(color: cs.outline.withValues(alpha: 0.35)),
          ),
        ),
        child: Center(
          child: Text(
            locale == 'ru' ? 'Реклама' : 'Advertisement',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.78),
                ),
          ),
        ),
      ),
    );
  }
}
