import 'dart:math';
import 'package:flutter/material.dart';
import '../models/exercise.dart';

class WordMatchExercise extends StatefulWidget {
  final Exercise exercise;
  final String locale;
  final bool useCyrillic;
  final void Function(bool correct, int xp) onComplete;

  const WordMatchExercise({
    super.key,
    required this.exercise,
    required this.locale,
    required this.useCyrillic,
    required this.onComplete,
  });

  @override
  State<WordMatchExercise> createState() => _WordMatchExerciseState();
}

class _WordMatchExerciseState extends State<WordMatchExercise> {
  late List<Map<String, dynamic>> _pairs;
  late List<String> _leftItems;
  late List<String> _rightItems;
  int? _selectedLeft;
  int? _selectedRight;
  final Map<int, int> _matched = {};
  final Set<int> _wrongPairs = {};
  bool _showHint = false;
  int _attempts = 0;

  @override
  void initState() {
    super.initState();
    _pairs = widget.exercise.pairs ?? [];
    _leftItems = _pairs
        .map((p) => widget.useCyrillic
            ? (p['isv_cyr'] ?? p['isv_lat'] ?? '') as String
            : (p['isv_lat'] ?? '') as String)
        .toList();
    _rightItems = _pairs
        .map((p) =>
            (widget.locale == 'ru' ? p['ru'] : p['en']) as String? ?? '')
        .toList();
    // Shuffle right side
    final rng = Random();
    for (int i = _rightItems.length - 1; i > 0; i--) {
      int j = rng.nextInt(i + 1);
      final temp = _rightItems[i];
      _rightItems[i] = _rightItems[j];
      _rightItems[j] = temp;
    }
  }

  void _selectLeft(int index) {
    if (_matched.containsKey(index)) return;
    setState(() {
      _selectedLeft = index;
      _wrongPairs.clear();
      if (_selectedRight != null) _tryMatch();
    });
  }

  void _selectRight(int index) {
    if (_matched.containsValue(index)) return;
    setState(() {
      _selectedRight = index;
      _wrongPairs.clear();
      if (_selectedLeft != null) _tryMatch();
    });
  }

  void _tryMatch() {
    final leftIdx = _selectedLeft!;
    final rightIdx = _selectedRight!;

    final correctTranslation =
        (widget.locale == 'ru' ? _pairs[leftIdx]['ru'] : _pairs[leftIdx]['en'])
                as String? ??
            '';

    if (_rightItems[rightIdx] == correctTranslation) {
      _matched[leftIdx] = rightIdx;
      _selectedLeft = null;
      _selectedRight = null;

      if (_matched.length == _pairs.length) {
        widget.onComplete(true, widget.exercise.xp);
      }
    } else {
      _attempts++;
      if (_attempts >= 2) {
        _showHint = true;
      }
      _wrongPairs.add(leftIdx);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _selectedLeft = null;
            _selectedRight = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          Expanded(
            child: Row(
              children: [
                // Left column (ISV)
                Expanded(
                  child: ListView.builder(
                    itemCount: _leftItems.length,
                    itemBuilder: (_, i) {
                      final isMatched = _matched.containsKey(i);
                      final isSelected = _selectedLeft == i;
                      final isWrong = _wrongPairs.contains(i);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _MatchTile(
                          text: _leftItems[i],
                          isSelected: isSelected,
                          isMatched: isMatched,
                          isWrong: isWrong,
                          onTap: () => _selectLeft(i),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Right column (translation)
                Expanded(
                  child: ListView.builder(
                    itemCount: _rightItems.length,
                    itemBuilder: (_, i) {
                      final isMatched = _matched.containsValue(i);
                      final isSelected = _selectedRight == i;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _MatchTile(
                          text: _rightItems[i],
                          isSelected: isSelected,
                          isMatched: isMatched,
                          isWrong: false,
                          onTap: () => _selectRight(i),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
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

class _MatchTile extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isMatched;
  final bool isWrong;
  final VoidCallback onTap;

  const _MatchTile({
    required this.text,
    required this.isSelected,
    required this.isMatched,
    required this.isWrong,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    if (isMatched) {
      bgColor = Colors.green.shade50;
      borderColor = Colors.green;
    } else if (isWrong) {
      bgColor = Colors.red.shade50;
      borderColor = Colors.red;
    } else if (isSelected) {
      bgColor = Colors.blue.shade50;
      borderColor = Colors.blue;
    } else {
      bgColor = Colors.white;
      borderColor = Colors.grey.shade300;
    }

    return Material(
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: borderColor, width: isSelected ? 2 : 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: isMatched ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isMatched ? Colors.green.shade700 : null,
              decoration: isMatched ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
      ),
    );
  }
}
