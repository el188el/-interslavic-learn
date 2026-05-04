import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../services/feedback_service.dart';
import '../services/supabase_service.dart';
import 'app_feedback_sheet.dart';

/// Нижняя полоса «заметили ошибку» для экранов курса и настроек.
class CourseFeedbackBar extends ConsumerWidget {
  const CourseFeedbackBar({
    super.key,
    required this.screen,
    this.lessonId,
    this.categoryId,
  });

  final FeedbackScreenKind screen;
  final String? lessonId;
  final String? categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isSupabaseConfigured) return const SizedBox.shrink();
    final locale = ref.watch(localeProvider);
    final ru = locale == 'ru';
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Center(
        child: TextButton.icon(
          onPressed: () => showAppFeedbackSheet(
            context,
            ref,
            screen: screen,
            lessonId: lessonId,
            categoryId: categoryId,
          ),
          icon: Icon(Icons.feedback_outlined, size: 20, color: cs.primary),
          label: Text(
            ru
                ? 'Ошибка в курсе или идея? Напишите нам'
                : 'Spotted a mistake or have a suggestion? Contact us',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  decoration: TextDecoration.underline,
                  decorationColor: cs.onSurfaceVariant.withValues(alpha: 0.5),
                ),
          ),
        ),
      ),
    );
  }
}
