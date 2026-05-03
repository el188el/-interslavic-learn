import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interslavic_learn/widgets/interslavic_char_strip.dart';

void main() {
  test('insertAtCursor appends when selection is whole text', () {
    final c = TextEditingController(text: 'ab');
    c.selection = const TextSelection(baseOffset: 0, extentOffset: 2);
    insertAtCursor(c, 'č');
    expect(c.text, 'abč');
    expect(c.selection.isCollapsed, isTrue);
    expect(c.selection.extentOffset, 3);
  });

  test('insertAtCursor replaces selection', () {
    final c = TextEditingController(text: 'hello');
    c.selection = const TextSelection(baseOffset: 1, extentOffset: 4);
    insertAtCursor(c, 'x');
    expect(c.text, 'hxo');
  });
}
