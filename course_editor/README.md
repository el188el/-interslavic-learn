# Course Editor — веб-админка курса

Flutter Web: правка категорий и уроков в **Supabase** (`course_categories`, `course_lessons`), теория (блоки text / tip / vocabulary_table / grammar_table), упражнения (word_match, multiple_choice, fill_blank, text_input), экспорт JSON в формате `course_import/full_course.json`.

## Требования

- Проект Supabase с таблицами из `supabase/schema.sql` и миграциями **002** (админ) и **003** (по желанию).
- В таблице `profiles` у вашего пользователя **`is_admin = true`** (SQL Editor).

## Запуск локально

```bash
cd course_editor
flutter pub get
flutter run -d chrome ^
  --dart-define=SUPABASE_URL=https://ВАШ.supabase.co ^
  --dart-define=SUPABASE_ANON_KEY=eyJ...
```

Шаблон переменных: `dart_defines.example.json` (как в основном приложении).

## Сборка для хостинга

```bash
flutter build web --base-href /course-editor/
```

(подставьте свой путь под GitHub Pages или другой хостинг.)

## Примечания

- Вход — **email + пароль** того же Supabase Auth, что и в приложении.
- Сохранение урока сразу пишет в БД (после выхода из экрана редактора по кнопке «Сохранить»).
- Экспорт копирует JSON в буфер обмена (можно вставить в файл и закоммитить в `course_import/full_course.json` при необходимости).
