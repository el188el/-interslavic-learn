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

### Offline-First

Приложение использует архитектуру **offline-first**: все уроки и данные предзагружены в виде JSON-seed и хранятся локально через Hive. Прогресс пользователя сохраняется на устройстве и синхронизируется с Supabase при наличии интернета.

The app uses an **offline-first** architecture: all lessons and data are pre-loaded as JSON seed and stored locally via Hive. User progress is saved on-device and synced to Supabase when online.

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

- **Flutter SDK** >= 3.41 (stable channel)
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

### 3. Настройка Supabase (опционально) / Set Up Supabase (Optional)

1. Создайте проект на [supabase.com](https://supabase.com)
2. Выполните SQL из `supabase/schema.sql` в SQL Editor
3. Настройте Auth (Email/Password)
4. Добавьте URL и anon key в конфигурацию приложения

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

1. **Сопоставление слов (Word Match)** — перетаскивание пар ISV ↔ перевод
2. **Множественный выбор (Multiple Choice)** — выберите перевод из 4 вариантов
3. **Заполнение пропусков (Fill in the Blank)** — впишите пропущенное слово
4. **Ввод текста (Text Input)** — напишите перевод самостоятельно

При ошибке **не показывается правильный ответ** — вместо этого появляется подсказка.

---

## Источники данных / Data Sources

- Грамматика: [interslavic.fun](https://interslavic.fun) (скраплено автоматически)
- Словарь: [interslavic-dictionary.com](https://interslavic-dictionary.com)
- GitHub: [medzuslovjansky](https://github.com/medzuslovjansky)

---

## Лицензия / License

MIT
