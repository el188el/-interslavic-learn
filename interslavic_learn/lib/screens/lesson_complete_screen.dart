import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/lesson.dart';
import '../providers/app_providers.dart';
import '../widgets/app_chrome_background.dart';
import '../widgets/glass_panel.dart';
import '../widgets/gradient_cta_button.dart';
import '../widgets/learning_orb.dart';

class LessonCompleteScreen extends ConsumerWidget {
  final Lesson lesson;
  final int xpEarned;
  final int correctAnswers;
  final int totalExercises;

  const LessonCompleteScreen({
    super.key,
    required this.lesson,
    required this.xpEarned,
    required this.correctAnswers,
    required this.totalExercises,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final progress = ref.watch(userProgressProvider);
    final cs = Theme.of(context).colorScheme;
    final percentage =
        totalExercises > 0 ? (correctAnswers / totalExercises * 100).round() : 0;

    return Scaffold(
      body: AppChromeBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
            child: Column(
              children: [
                const SizedBox(height: 12),
                const LearningOrb(size: 100),
                const SizedBox(height: 20),
                Text(
                  locale == 'ru' ? 'Урок завершён!' : 'Lesson complete!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    height: 1.15,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  lesson.title(locale),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: _GlassStat(
                        icon: Icons.star_rounded,
                        value: '+$xpEarned',
                        label: 'XP',
                        accent: const Color(0xFFFBBF24),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _GlassStat(
                        icon: Icons.psychology_rounded,
                        value: '$percentage%',
                        label: locale == 'ru' ? 'Точность' : 'Accuracy',
                        accent: cs.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _GlassStat(
                        icon: Icons.local_fire_department_rounded,
                        value: '${progress.currentStreak}',
                        label: locale == 'ru' ? 'Серия' : 'Streak',
                        accent: const Color(0xFFFF7A45),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                GlassPanel(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  borderRadius: 18,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star_outline_rounded,
                          color: cs.primary, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        '${locale == 'ru' ? 'Всего XP' : 'Total XP'}: ${progress.totalXp}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$correctAnswers / $totalExercises ${locale == 'ru' ? 'правильно' : 'correct'}',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 28),
                GradientCtaButton(
                  onPressed: () {
                    Navigator.of(context)
                      ..pop()
                      ..pop();
                  },
                  label: locale == 'ru' ? 'Продолжить' : 'Continue',
                  icon: Icons.arrow_forward_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassStat extends StatelessWidget {
  const _GlassStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      borderRadius: 18,
      child: Column(
        children: [
          Icon(icon, color: accent, size: 26),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
