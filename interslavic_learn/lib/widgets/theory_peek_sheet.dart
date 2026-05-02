import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/lesson.dart';
import '../providers/app_providers.dart';
import 'glass_panel.dart';
import 'lesson_theory_blocks.dart';

Future<void> showTheoryPeekSheet(
  BuildContext context,
  Lesson lesson,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: false,
    builder: (ctx) {
      return Consumer(
        builder: (context, ref, _) {
          final locale = ref.watch(localeProvider);
          final useCyrillic = ref.watch(useCyrillicProvider);
          final cs = Theme.of(context).colorScheme;

          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.48,
            minChildSize: 0.28,
            maxChildSize: 0.92,
            builder: (_, scrollController) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 6),
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: cs.outline.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              lesson.theory.title(locale),
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          GlassPanel(
                            padding: const EdgeInsets.all(4),
                            borderRadius: 14,
                            child: SegmentedButton<bool>(
                              segments: const [
                                ButtonSegment(value: false, label: Text('Lat')),
                                ButtonSegment(
                                    value: true, label: Text('Кир')),
                              ],
                              selected: {useCyrillic},
                              onSelectionChanged: (v) {
                                ref.read(useCyrillicProvider.notifier).state =
                                    v.first;
                              },
                              style: ButtonStyle(
                                visualDensity: VisualDensity.compact,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                side: WidgetStateProperty.all(BorderSide.none),
                                backgroundColor:
                                    WidgetStateProperty.resolveWith((s) {
                                  if (s.contains(WidgetState.selected)) {
                                    return cs.primary.withValues(alpha: 0.35);
                                  }
                                  return Colors.transparent;
                                }),
                                foregroundColor:
                                    WidgetStateProperty.all(cs.onSurface),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                            tooltip: locale == 'ru' ? 'Закрыть' : 'Close',
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
                        children: [
                          for (final block in lesson.theory.blocks)
                            LessonTheoryBlockWidget(
                              block: block,
                              locale: locale,
                              useCyrillic: useCyrillic,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}
