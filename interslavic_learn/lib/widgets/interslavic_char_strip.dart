import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Вставка символов этимологической латиницы и кириллицы Medžuslovjansky,
/// которых нет на обычной EN/RU клавиатуре. Дополняет системные раскладки (MSKLC и т.д.).
///
/// Символы сверены с учебной орфографией; полные раскладки см. внешние ресурсы.
void insertAtCursor(TextEditingController controller, String insertion) {
  final value = controller.value;
  final text = value.text;
  final sel = value.selection;

  int start = sel.isValid ? sel.start : text.length;
  int end = sel.isValid ? sel.end : text.length;

  // Flutter Web: при тапе по полоске поле теряет фокус и выделение часто
  // превращается в «весь текст» — тогда replaceRange стирает ответ целиком.
  // Считаем это артефактом и вставляем в конец (как часто нужно при наборе).
  if (sel.isValid &&
      start == 0 &&
      end == text.length &&
      text.isNotEmpty &&
      end > start) {
    start = end = text.length;
  }

  final safeStart = start.clamp(0, text.length);
  final safeEnd = end.clamp(safeStart, text.length);
  final newText = text.replaceRange(safeStart, safeEnd, insertion);
  final newOffset = safeStart + insertion.length;
  controller.value = TextEditingValue(
    text: newText,
    selection: TextSelection.collapsed(offset: newOffset),
  );
}

/// Латиница (элементы вне базовой US-клавиатуры).
const _latinStrip = <String>[
  'ě',
  'č',
  'š',
  'ž',
  'ć',
  'ń',
  'ś',
  'ź',
  'ř',
  'ď',
  'ť',
  'ľ',
  'ň',
  'ę',
  'ų',
  'ů',
  'ó',
  'ą',
];

/// Кириллица Medžuslovjansky (буквы вне типичной русской раскладки).
const _cyrillicStrip = <String>[
  'ј',
  'љ',
  'њ',
  'ћ',
  'ђ',
  'є',
  'ѕ',
  'і',
  'ї',
  'ґ',
  'ў',
];

/// Горизонтальная полоса кнопок: вставка в [controller] в позицию курсора.
class InterslavicCharStrip extends StatelessWidget {
  const InterslavicCharStrip({
    super.key,
    required this.controller,
    required this.useCyrillic,
    required this.locale,
  });

  final TextEditingController controller;
  final bool useCyrillic;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final chars = useCyrillic ? _cyrillicStrip : _latinStrip;
    final label = locale == 'ru'
        ? 'Буквы межславянского (нажмите для вставки)'
        : 'Interslavic letters (tap to insert)';
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        Focus(
          canRequestFocus: false,
          skipTraversal: true,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final ch in chars)
                  Padding(
                    padding: const EdgeInsets.only(right: 6, bottom: 4),
                    child: Material(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          insertAtCursor(controller, ch);
                          HapticFeedback.lightImpact();
                          // Не вызываем requestFocus: на Web это часто даёт «выделить всё».
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            final v = controller.value;
                            if (!v.selection.isValid) return;
                            final off = v.selection.extentOffset
                                .clamp(0, v.text.length);
                            if (controller.selection.baseOffset != off ||
                                !controller.selection.isCollapsed) {
                              controller.selection =
                                  TextSelection.collapsed(offset: off);
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Text(
                            ch,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
