import 'dart:convert';

/// Сохранённый прогресс по уроку: с какого упражнения продолжить и за какие уже начислен XP.
class LessonCheckpoint {
  const LessonCheckpoint({
    required this.resumeExerciseIndex,
    required this.xpGrantedExerciseIndices,
  });

  final int resumeExerciseIndex;
  final List<int> xpGrantedExerciseIndices;

  Map<String, dynamic> toJson() => {
        'r': resumeExerciseIndex,
        'g': xpGrantedExerciseIndices,
      };

  factory LessonCheckpoint.fromJson(Map<String, dynamic> json) {
    return LessonCheckpoint(
      resumeExerciseIndex: json['r'] as int? ?? 0,
      xpGrantedExerciseIndices: (json['g'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
    );
  }

  String encode() => jsonEncode(toJson());

  static LessonCheckpoint? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return LessonCheckpoint.fromJson(m);
    } catch (_) {
      return null;
    }
  }
}
