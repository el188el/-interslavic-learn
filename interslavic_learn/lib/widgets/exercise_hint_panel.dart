import 'package:flutter/material.dart';

/// Заметная подсказка к упражнению (показываем сразу, если текст есть в данных).
class ExerciseHintPanel extends StatelessWidget {
  const ExerciseHintPanel({
    super.key,
    required this.locale,
    required this.text,
  });

  final String locale;
  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: cs.tertiaryContainer.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.tips_and_updates_rounded,
                  color: cs.tertiary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locale == 'ru' ? 'Подсказка' : 'Hint',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: cs.onTertiaryContainer,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      text,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.35,
                            color: cs.onTertiaryContainer,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
