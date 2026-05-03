import 'package:flutter/material.dart';

import '../../config/monetization_config.dart';
import '../../models/user_progress.dart';

class ProfilePremiumCard extends StatelessWidget {
  const ProfilePremiumCard({
    super.key,
    required this.progress,
    required this.locale,
  });

  final UserProgress progress;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final isRu = locale == 'ru';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  isRu ? 'Премиум' : 'Premium',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              progress.isPremium
                  ? (isRu
                      ? 'Премиум активен — реклама в приложении не показывается.'
                      : 'Premium is active — ads are not shown in the app.')
                  : (isRu
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
                        content: Text(
                          isRu
                              ? 'Оплата премиума будет в RuStore и на странице загрузки APK.'
                              : 'Premium purchase will be available in RuStore and on the APK download page.',
                        ),
                      ),
                    );
                  },
                  child: Text(
                    isRu
                        ? 'Оформить — ${MonetizationConfig.premiumPriceRub} ₽'
                        : 'Get Premium — ${MonetizationConfig.premiumPriceRub} ₽',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
