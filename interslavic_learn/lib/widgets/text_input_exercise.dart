import 'package:flutter/material.dart';
import '../models/exercise.dart';
import 'exercise_hint_panel.dart';
import 'interslavic_char_strip.dart';

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
  final _focus = FocusNode();
  bool? _isCorrect;

  void _check() {
    final input = _controller.text.trim().toLowerCase();
    final correctLat =
        (widget.exercise.answerIsvLat ?? '').trim().toLowerCase();
    final correctCyr =
        (widget.exercise.answerIsvCyr ?? '').trim().toLowerCase();

    final bothCanonicalEmpty = correctLat.isEmpty && correctCyr.isEmpty;
    final correct = bothCanonicalEmpty
        ? input.isEmpty
        : (correctLat.isNotEmpty && input == correctLat) ||
            (correctCyr.isNotEmpty && input == correctCyr);

    setState(() {
      _isCorrect = correct;
    });

    if (correct) {
      widget.onComplete(true, widget.exercise.xp);
    } else {
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
    _focus.dispose();
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
          InterslavicCharStrip(
            controller: _controller,
            useCyrillic: widget.useCyrillic,
            locale: widget.locale,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            focusNode: _focus,
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
        ],
      ),
    );
  }
}
