import 'package:flutter_test/flutter_test.dart';
import 'package:interslavic_learn/models/category.dart';

void main() {
  test('Category.fromJson and title()', () {
    final c = Category.fromJson({
      'id': 'basics',
      'title_ru': 'Основы',
      'title_en': 'Basics',
      'title_isv_lat': 'Osnovy',
      'title_isv_cyr': 'Основы',
      'icon': 'school',
      'order': 1,
    });
    expect(c.id, 'basics');
    expect(c.title('ru'), 'Основы');
    expect(c.title('en'), 'Basics');
    expect(c.icon, 'school');
    expect(c.order, 1);
  });

  test('Category.fromDbRow uses sort_order', () {
    final c = Category.fromDbRow({
      'id': 'x',
      'title_ru': 'r',
      'title_en': 'e',
      'sort_order': 42,
    });
    expect(c.order, 42);
  });
}
