import 'package:flutter/material.dart';

import '../../layout/app_breakpoints.dart';

/// Бейдж XP в шапке каталога курсов.
class HomeXpBadge extends StatelessWidget {
  const HomeXpBadge({super.key, required this.xp});

  final int xp;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final w = MediaQuery.sizeOf(context).width;
    final compact = w >= AppBreakpoints.medium;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: compact ? 3 : 4),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded,
              color: cs.primary, size: compact ? 16 : 18),
          const SizedBox(width: 4),
          Text(
            '$xp',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: cs.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

/// Бейдж серии (огонёк) в шапке.
class HomeStreakBadge extends StatelessWidget {
  const HomeStreakBadge({super.key, required this.streak});

  final int streak;

  static const _fireActive = Color(0xFFFF7A45);
  static const _fireMuted = Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final w = MediaQuery.sizeOf(context).width;
    final compact = w >= AppBreakpoints.medium;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: compact ? 3 : 4),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: cs.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.outline.withValues(alpha: 0.28),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            color: streak > 0 ? _fireActive : _fireMuted,
            size: compact ? 16 : 18,
          ),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: cs.onTertiaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
