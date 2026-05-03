import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interslavic_learn/screens/home/category_material_icon_map.dart';

void main() {
  test('known keys map to icons', () {
    expect(categoryMaterialIcon('school'), Icons.school);
    expect(categoryMaterialIcon('restaurant'), Icons.restaurant);
  });

  test('unknown key falls back to book', () {
    expect(categoryMaterialIcon('nonexistent_key_xyz'), Icons.book);
  });
}
