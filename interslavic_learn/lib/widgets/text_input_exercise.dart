import 'package:flutter/material.dart';
import '../models/exercise.dart';

class TextInputExercise extends StatefulWidget {
  final Exercise exercise;
  final String locale;
  final bool useCyrillic;
  final void Function(bool correct, int xp) onComplete;

  const TextInputExercise({
    super.key,
    required this.exercise,
    required this.locale,
    required this.useCyrillic,
    required this.onComplete,
  });

  @override
  State<TextInputExercise> createState() => _TextInputExerciseState();
}

class _TextInputExerciseState extends State<TextInputExercise> {
  final _controller = TextEditingController();
  bool? _isCorrect;
  bool _showHint = false;
  int _attempts = 0;

  void _check() {
    final input = _controller.text.trim().toLowerCase();
    final correctLat =
        (widget.exercise.answerIsvLat ?? '').trim().toLowerCase();
    final correctCyr =
        (widget.exercise.answerIsvCyr ?? '').trim().toLowerCase();

    final correct = input == correctLat || input == correctCyr;

    setState(() {
      _isCorrect = correct;
    });

    if (correct) {
      widget.onComplete(true, widget.exercise.xp);
    } else {
      _attempts++;
      if (_attempts >= 1) {
        setState(() => _showHint = true);
      }
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isCorrect = null;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prompt = widget.exercise.prompt(widget.locale) ?? '';

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
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  prompt,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context)
                            .colorScheme
                            .onSecondaryContainer,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Icon(
                  Icons.arrow_downward,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: widget.locale == 'ru'
                  ? 'Напишите на межславянском'
                  : 'Write in Interslavic',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: _isCorrect == null
                  ? null
                  : Icon(
                      _isCorrect! ? Icons.check_circle : Icons.cancel,
                      color: _isCorrect! ? Colors.green : Colors.red,
                    ),
            ),
            onSubmitted: (_) => _check(),
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isCorrect == true ? null : _check,
              child: Text(widget.locale == 'ru' ? 'Проверить' : 'Check'),
            ),
          ),
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
