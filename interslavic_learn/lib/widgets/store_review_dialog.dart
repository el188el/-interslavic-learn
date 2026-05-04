import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/app_providers.dart';

const kRuStoreAppUrl =
    'https://www.rustore.ru/catalog/app/com.interslavic.interslavic_learn';

Future<void> showRuStoreReviewDialog(BuildContext context, WidgetRef ref) async {
  final ru = ref.read(localeProvider) == 'ru';
  final go = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: Text(ru ? 'Оцените приложение' : 'Rate the app'),
      content: Text(
        ru
            ? 'Вы уже прошли несколько уроков. Если Interslavic Learn вам зашёл, оставьте отзыв в RuStore — так о приложении узнают другие.'
            : 'You have completed several lessons. If you enjoy Interslavic Learn, leave a review on RuStore so others can discover it.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(ru ? 'Позже' : 'Not now'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(ru ? 'В RuStore' : 'Open RuStore'),
        ),
      ],
    ),
  );

  if (go == true && context.mounted) {
    final uri = Uri.parse(kRuStoreAppUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ru ? 'Не удалось открыть ссылку' : 'Could not open link'),
        ),
      );
    }
  }
}
