import 'package:flutter/material.dart';
import '../models/exercise.dart';

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
  bool _showHint = false;
  int _attempts = 0;

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
      _attempts++;
      if (_attempts >= 1) {
        setState(() => _showHint = true);
      }
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
            Color? tileColor;
            IconData? trailing;

            if (_selectedIndex == i) {
              if (_isCorrect == true) {
                tileColor = Colors.green.shade100;
                trailing = Icons.check_circle;
              } else {
                tileColor = Colors.red.shade100;
                trailing = Icons.cancel;
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: tileColor ?? Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _selectedIndex == i
                        ? (_isCorrect == true ? Colors.green : Colors.red)
                        : Colors.grey.shade300,
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
                          backgroundColor: Colors.grey.shade200,
                          child: Text(
                            String.fromCharCode(65 + i),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(opt,
                              style: const TextStyle(fontSize: 16)),
                        ),
                        if (trailing != null)
                          Icon(trailing,
                              color: _isCorrect == true
                                  ? Colors.green
                                  : Colors.red),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          if (_showHint)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.exercise.hint(widget.locale) ?? '',
                      style: TextStyle(color: Colors.amber.shade900),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
