import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/lesson.dart';
import 'glass_panel.dart';

double theoryTipAlpha(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? 0.12 : 0.15;

/// Один блок теории (текст, совет, таблицы).
class LessonTheoryBlockWidget extends StatelessWidget {
  const LessonTheoryBlockWidget({
    super.key,
    required this.block,
    required this.locale,
    required this.useCyrillic,
  });

  final TheoryBlock block;
  final String locale;
  final bool useCyrillic;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    switch (block.type) {
      case 'text':
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Text(
            block.content(locale) ?? '',
            style: GoogleFonts.inter(
              height: 1.55,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: cs.onSurface,
            ),
          ),
        );

      case 'tip':
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: GlassPanel(
            padding: const EdgeInsets.all(18),
            borderRadius: 18,
            tint: cs.secondary.withValues(alpha: theoryTipAlpha(context)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_rounded,
                  size: 22,
                  color: cs.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    block.content(locale) ?? '',
                    style: GoogleFonts.inter(
                      height: 1.45,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      case 'vocabulary_table':
        final items = block.items ?? [];
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: GlassPanel(
            padding: EdgeInsets.zero,
            borderRadius: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.88),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(19)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          useCyrillic
                              ? 'Меджусловјанскы'
                              : 'Medžuslovjansky',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          locale == 'ru' ? 'Перевод' : 'Translation',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0)
                    Divider(
                        height: 1, color: cs.outline.withValues(alpha: 0.25)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 13),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            useCyrillic
                                ? (items[i]['isv_cyr'] ??
                                        items[i]['isv_lat'] ??
                                        '') as String
                                : (items[i]['isv_lat'] ?? '') as String,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            (locale == 'ru'
                                    ? items[i]['ru']
                                    : items[i]['en']) as String? ??
                                '',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );

      case 'grammar_table':
        final rows = block.rows ?? [];
        if (rows.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: GlassPanel(
            padding: EdgeInsets.zero,
            borderRadius: 20,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minWidth: constraints.maxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: rows.asMap().entries.map((entry) {
                        final isHeader = entry.key == 0;
                        return Container(
                          decoration: BoxDecoration(
                            color: isHeader
                                ? cs.primary.withValues(alpha: 0.35)
                                : null,
                            border: Border(
                              bottom: BorderSide(
                                color: cs.outline.withValues(alpha: 0.2),
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: entry.value.map((cell) {
                              return Expanded(
                                child: Text(
                                  cell,
                                  style: GoogleFonts.inter(
                                    fontWeight: isHeader
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                    fontSize: 14,
                                    color: cs.onSurface,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
