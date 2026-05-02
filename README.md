# Interslavic Learn (Меджусловјанскы)

Кроссплатформенное (Web, Android, iOS) приложение для изучения **межславянского языка (Medžuslovjansky)**.

A cross-platform (Web, Android, iOS) app for learning the **Interslavic (Medžuslovjansky)** language.

---

## Архитектура / Architecture

| Компонент | Технология |
|-----------|-----------|
| Frontend | Flutter (Dart) |
| State management | Riverpod |
| Offline storage | Hive |
| Backend | Supabase (PostgreSQL, Auth, Realtime) |
| Scraper | Python 3 (requests + BeautifulSoup) |

### Данные и прогресс

- **Гость** — прогресс и имя `gost_*` только в **Hive**; после удаления приложения данные теряются (есть предупреждение в UI).
- **Email + Supabase** — профиль и прогресс в **PostgreSQL**; синхронизация после входа и по завершении урока.
- **Курсы** — при непустых таблицах `course_categories` / `course_lessons` в Supabase данные читаются **оттуда**, иначе используется `assets/data/seed_data.json`.

### Один файл сида / Single seed file

После `python scraper.py` скопируйте `scraper/data/seed_data.json` → `interslavic_learn/assets/data/seed_data.json` (это каноничный путь для релиза).

---

## Возможности / Features

- **Свободный выбор уроков** — без линейных блокировок, можно начать с любой темы
- **Теория перед упражнениями** — каждый урок начинается с грамматики и словаря
- **Переключение кириллица/латиница** — глобальный тогл в любой момент
- **4 типа упражнений**: сопоставление слов, выбор перевода, заполнение пропусков, ввод текста
- **Подсказки при ошибках** — не показывается правильный ответ сразу, вместо этого даётся подсказка
- **XP и серии (streaks)** — система очков опыта и ежедневных серий
- **Глобальный рейтинг** — таблица лидеров с синхронизацией через бэкенд
- **Мягкий фримиум** — весь контент бесплатен, премиум только для косметики и статистики
- **Русский / English** — интерфейс на двух языках

---

## Структура проекта / Project Structure

```
├── scraper/                    # Python-скрапер для interslavic.fun
│   ├── scraper.py              # Основной скрипт
│   ├── requirements.txt
│   └── data/                   # Сгенерированные JSON-данные
│       ├── grammar_raw.json
│       ├── vocabulary_raw.json
│       └── seed_data.json      # Сид-данные для приложения
├── interslavic_learn/          # Flutter-приложение
│   ├── lib/
│   │   ├── main.dart           # Точка входа
│   │   ├── models/             # Модели данных
│   │   ├── providers/          # Riverpod-провайдеры
│   │   ├── screens/            # Экраны (Home, Theory, Exercise, ...)
│   │   ├── widgets/            # Виджеты упражнений
│   │   └── services/           # Сервисы (данные, прогресс)
│   ├── assets/data/            # Seed JSON
│   ├── pubspec.yaml
│   └── test/
├── supabase/
│   └── schema.sql              # Схема БД (Users, Progress, Leaderboard, Sync)
└── README.md
```

---

## Запуск / Getting Started

### Предварительные требования / Prerequisites

- **Flutter SDK** — см. `interslavic_learn/pubspec.yaml` (`environment.sdk`)
- **Python 3.10+** (для скрапера)
- **Chrome** (для web-сборки)

### 1. Запуск скрапера / Run the Scraper

```bash
cd scraper
pip install -r requirements.txt
python scraper.py
```

Это создаст файлы в `scraper/data/`, включая `seed_data.json`.

### 2. Запуск Flutter-приложения / Run the Flutter App

```bash
cd interslavic_learn
flutter pub get
flutter run -d chrome      # Web
flutter run -d android     # Android (нужен эмулятор или устройство)
flutter run -d ios         # iOS (нужен Mac с Xcode)
```

### 3. Supabase (для аккаунта и рейтинга)

1. Проект на [supabase.com](https://supabase.com)
2. SQL Editor: выполнить `supabase/schema.sql`
3. Authentication → провайдер **Email** (для разработки можно отключить подтверждение email)
4. Сборка с ключами (пример):

```bash
cd interslavic_learn
flutter run -d chrome --dart-define=SUPABASE_URL=https://xxxx.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJhbG...
```

Без `dart-define` гость и локальный сид работают; облако и глобальный рейтинг — только с настроенным Supabase.

---

## Категории уроков / Lesson Categories

| Категория | Category | Уроки |
|-----------|----------|-------|
| Основы | Basics | Основные слова и фразы |
| Приветствия | Greetings | Приветствия и знакомство |
| Еда и напитки | Food & Drinks | Продукты, напитки |
| Семья | Family | Родственники |
| Числа | Numbers | 1-10 |
| Цвета | Colors | Основные цвета |
| Путешествия | Travel | Транспорт, города |
| Грамматика: Существительные | Grammar: Nouns | Склонения, рода |
| Грамматика: Глаголы | Grammar: Verbs | Спряжения |
| Грамматика: Прилагательные | Grammar: Adjectives | Согласование |
| Грамматика: Местоимения | Grammar: Pronouns | Личные, падежные |
| Грамматика: Предлоги | Grammar: Prepositions | Основные предлоги |

---

## Упражнения / Exercise Types

1. **Сопоставление слов (Word Match)** — выбор пар ISV ↔ перевод (тап)
2. **Множественный выбор (Multiple Choice)** — выберите перевод из 4 вариантов
3. **Заполнение пропусков (Fill in the Blank)** — впишите пропущенное слово
4. **Ввод текста (Text Input)** — напишите перевод самостоятельно

При ошибке **не показывается правильный ответ** — вместо этого появляется подсказка.

---

## Источники и сообщество / Resources

Контент и идеи для курсов (от начального уровня до продвинутого), аудио и справка:

- [interslavic.fun](https://interslavic.fun/) — курс и материалы
- [interslavic-dictionary.com](https://interslavic-dictionary.com/) — словарь (проект [sonic16x/interslavic](https://github.com/sonic16x/interslavic))
- [isv.miraheze.org](https://isv.miraheze.org/) — Medžuviki
- [steen.free.fr/interslavic](http://steen.free.fr/interslavic/) — классические материалы
- [github.com/medzuslovjansky](https://github.com/medzuslovjansky) — официальные OSS-проекты
- [interslavic-language.org](https://interslavic-language.org/) — портал языка

В приложении пакет **audioplayers** зарезервирован под озвучку фраз из этих источников.

---

## Лицензия / License

MIT
