import 'package:flutter/material.dart';
import '../models/exercise.dart';
import 'exercise_hint_panel.dart';

class MultipleChoiceExercise extends StatefulWidget {
  final Exercise exercise;
  final String locale;
  final bool useCyrillic;
  final void Function(bool correct, int xp) onComplete;

  const MultipleChoiceExercise({
    super.key,
    required this.exercise,
    required this.locale,
    required this.useCyrillic,
    required this.onComplete,
  });

  @override
  State<MultipleChoiceExercise> createState() => _MultipleChoiceExerciseState();
}

class _MultipleChoiceExerciseState extends State<MultipleChoiceExercise> {
  int? _selectedIndex;
  bool? _isCorrect;

  void _select(int index) {
    if (_isCorrect == true) return;

    final correct = index == widget.exercise.correctIndex;
    setState(() {
      _selectedIndex = index;
      _isCorrect = correct;
    });

    if (correct) {
      widget.onComplete(true, widget.exercise.xp);
    } else {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _selectedIndex = null;
            _isCorrect = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.exercise.options(widget.locale) ?? [];
    final question = widget.exercise.questionIsv(widget.useCyrillic) ?? '';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.exercise.instruction(widget.locale),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (widget.exercise.hint(widget.locale)?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            ExerciseHintPanel(
              locale: widget.locale,
              text: widget.exercise.hint(widget.locale)!,
            ),
          ],
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              question,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color:
                        Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ...options.asMap().entries.map((entry) {
            final i = entry.key;
            final opt = entry.value;
            final cs = Theme.of(context).colorScheme;
            Color? tileColor;
            IconData? trailing;
            late final Color borderColor;

            if (_selectedIndex == i) {
              if (_isCorrect == true) {
                tileColor = cs.primaryContainer;
                borderColor = cs.primary;
                trailing = Icons.check_circle;
              } else {
                tileColor = cs.errorContainer;
                borderColor = cs.error;
                trailing = Icons.cancel;
              }
            } else {
              tileColor = null;
              borderColor = cs.outlineVariant;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: tileColor ?? cs.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: borderColor,
                    width: _selectedIndex == i ? 2 : 1,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _select(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: cs.surfaceContainerHigh,
                          child: Text(
                            String.fromCharCode(65 + i),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            opt,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontSize: 16,
                                  color: _selectedIndex == i
                                      ? (_isCorrect == true
                                          ? cs.onPrimaryContainer
                                          : cs.onErrorContainer)
                                      : cs.onSurface,
                                ),
                          ),
                        ),
                        if (trailing != null)
                          Icon(
                            trailing,
                            color: _isCorrect == true
                                ? cs.primary
                                : cs.error,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
        ],
      ),
    );
  }
}
