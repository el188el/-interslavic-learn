# Interslavic Learn

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-app-02569B?logo=flutter)](https://flutter.dev/)

**Бесплатное приложение** для изучения **межславянского** (Medžuslovjansky / Меджусловјанскы) — с курсами, теорией, упражнениями и прогрессом. Работает **в браузере** и на **Android**; облако и рейтинг — по желанию, через Supabase.

Учитесь **гостем** (всё хранится на устройстве) или **войдите по email**, чтобы синхронизировать прогресс. Интерфейс — **русский** и **английский**; тексты курса — **кириллица** или **латиница** одним переключателем.

> [!TIP]
> Весь учебный контент в приложении **бесплатен**. Сборки веба и APK для публичного сайта собираются **автоматически** в GitHub Actions из этого же репозитория — как исходники, так и то, что выкладывается на страницу, совпадают по версии.

> [!NOTE]
> **RuStore** — в планах; когда появится карточка приложения, ссылку добавят на [лендинг](landing/index.html) и сюда.

> [!CAUTION]
> Скачивайте **APK только с официального сайта** вашего проекта (GitHub Pages) или из **доверенного [релиза](https://github.com/el188el/-interslavic-learn/releases)**. Проверяйте адрес в браузере; не ставьте файлы из случайных чатов.

**Contributing:** [CONTRIBUTING.md](CONTRIBUTING.md) · **Security:** [SECURITY.md](SECURITY.md)

### Онлайн (GitHub Pages + релизы)

После первого успешного деплоя ([инструкция](.github/WEB_DEPLOY.txt)) ссылки обычно такие (имя репозитория с дефисом в начале — как у этого проекта):

| | Ссылка |
|---|--------|
| **Лендинг** | [el188el.github.io/-interslavic-learn/](https://el188el.github.io/-interslavic-learn/) |
| **Веб-версия приложения** | […/app/](https://el188el.github.io/-interslavic-learn/app/) |
| **APK** (после CI; версия в имени файла) | `https://el188el.github.io/-interslavic-learn/downloads/learn_interslavic_<версия>.apk` (сейчас в `pubspec.yaml`: **1.0.1**) |
| **Релизы на GitHub** | [github.com/el188el/-interslavic-learn/releases](https://github.com/el188el/-interslavic-learn/releases) |

**Карточка репозитория на GitHub:** Settings → General → в блоке **About** нажмите шестерёнку и в поле **Website** укажите URL лендинга — тогда ссылка будет видна справа на главной странице репозитория.

**Первый релиз (тег не переписывать):** когда `main` вас устраивает, создайте **аннотированный** тег с номером, совпадающим с версией приложения (например `v1.0.1`), отправьте его на GitHub (`git push origin v1.0.1`), затем на вкладке **Releases** → **Create a new release** выберите этот тег, кратко опишите изменения и опубликуйте. Исправления — новым тегом (`v1.0.2`), а не заменой старого.

---

## Как это устроено

```
┌─────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Вы / ученик │ ──► │  Flutter-приложение │ ──► │  Hive (гость)   │
└─────────────┘     │  Web / Android      │     │  или Supabase   │
                    └──────────────────┘     │  (email + облако)│
                                               └─────────────────┘
```

1. Открываете **веб** или **APK** — один и тот же функционал.
2. Курсы подгружаются из **встроенного сида** или из **таблиц Supabase**, если они уже заполнены.
3. Без аккаунта прогресс остаётся **только локально**; с аккаунтом — **синхронизация** и **таблица лидеров** (если настроен бэкенд).

---

## Быстрый старт (для учеников)

После настройки [GitHub Pages](https://docs.github.com/en/pages) (workflow **Deploy Web to GitHub Pages**, см. [.github/WEB_DEPLOY.txt](.github/WEB_DEPLOY.txt)) у вас появится сайт вида:

`https://<ваш-логин>.github.io/<имя-репозитория>/`

### В браузере

1. Откройте **корень сайта** — это [лендинг](landing/) с кратким описанием и кнопками.
2. Нажмите **«Веб-версия»** или перейдите сразу в каталог **`/app/`** (например `…/app/` — Flutter Web).

### Android (APK)

1. На том же сайте нажмите **«Скачать APK»** на лендинге — ссылка ведёт на файл с **версией в имени**, например **`learn_interslavic_1.0.1.apk`** (версия берётся из `interslavic_learn/pubspec.yaml` при деплое).
2. Прямой URL выглядит так: `https://<ваш-логин>.github.io/<имя-репозитория>/downloads/learn_interslavic_<версия>.apk` — при обновлении приложения меняется только **номер в имени файла**, так всегда видно, какой билд скачан.
3. На телефоне разрешите установку из браузера / «неизвестного источника», если система спросит.

Отдельно в репозитории есть workflow **Build Android APK** — он кладёт APK в артефакты запуска Actions (удобно для теста без Pages).

### RuStore

Скоро; следите за обновлениями репозитория.

---

## Возможности

- Свободный выбор тем — без жёсткой «стены» уроков  
- Теория перед упражнениями  
- Несколько типов заданий: пары, выбор, пропуск, ввод текста  
- Подсказки при ошибках (без мгновенного «выдавания» ответа)  
- XP, серии дней, глобальный рейтинг (с Supabase)  
- Два языка интерфейса: RU / EN  

---

## Readme in other languages

<details>
<summary><strong>English</strong></summary>

**Interslavic Learn** is a free **Flutter** app (Web + Android) to learn **Interslavic**. Guest mode keeps data on-device; email sign-in enables Supabase sync and leaderboard. UI: Russian / English; course script: Cyrillic / Latin.

**Try it:** [Landing](https://el188el.github.io/-interslavic-learn/) · [Web app](https://el188el.github.io/-interslavic-learn/app/) · [Releases](https://github.com/el188el/-interslavic-learn/releases) · APK path `…/downloads/learn_interslavic_<version>.apk` (version from `pubspec.yaml`).

**Develop:** `cd interslavic_learn && flutter pub get && flutter run`. For cloud, copy `dart_defines.example.json` → `dart_defines.json` (gitignored). Technical sections below are maintained in English.

</details>

<details>
<summary><strong>Medžuslovjansky (Latinica)</strong></summary>

**Interslavic Learn** jest besplatna aplikacija (web + Android) za učenje medžuslovjanskogo. Gost — dane na ustrojstvu; e-pošta — sinhronizacija čerez Supabase.

Po uspěšnom deploy: `https://<user>.github.io/<repo>/app/` i APK `…/downloads/learn_interslavic_<verzija>.apk`.

</details>

---

## Architecture

| Component | Technology |
|-----------|------------|
| App | Flutter (Dart), Riverpod |
| Local storage | Hive |
| Backend (optional) | Supabase — PostgreSQL, Auth |
| Scraper | Python 3 — `requests`, BeautifulSoup |
| CI | GitHub Actions — `.github/workflows/` |

### Data & progress

- **Guest** — progress and display name stay in **Hive** on the device; uninstall clears data (warning in the app).
- **Signed-in user** — profile and progress in **PostgreSQL**; sync after login and when lessons complete.
- **Course content** — if `course_categories` / `course_lessons` in Supabase are non-empty, the app reads from the database; otherwise it uses bundled `interslavic_learn/assets/data/seed_data.json`.

### Canonical seed file

After `python scraper.py` in `scraper/`, copy `scraper/data/seed_data.json` → `interslavic_learn/assets/data/seed_data.json` for release builds.

---

## Repository layout

```
├── interslavic_learn/       # Flutter learner app
│   ├── lib/
│   ├── assets/data/
│   └── pubspec.yaml
├── scraper/
├── supabase/
├── tool/
├── course_import/
├── landing/                 # Landing + stable APK URL on Pages
├── .github/workflows/
├── CONTRIBUTING.md
├── SECURITY.md
└── LICENSE
```

---

## Getting started (developers)

### 1. Scraper

```bash
cd scraper
pip install -r requirements.txt
python scraper.py
```

### 2. Flutter app

```bash
cd interslavic_learn
flutter pub get
flutter run -d chrome      # Web
flutter run -d android     # Android emulator or device
flutter run -d ios         # macOS + Xcode
```

### 3. Supabase (accounts & leaderboard)

1. Create a project on [supabase.com](https://supabase.com).
2. Run `supabase/schema.sql` in the SQL editor.
3. Enable the **Email** auth provider (you may disable email confirmation for dev).
4. Run with defines, for example:

```bash
cd interslavic_learn
flutter run -d chrome --dart-define=SUPABASE_URL=https://xxxx.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJhbG...
```

Without defines, guest mode and the local seed still work; cloud sync and the global leaderboard need a configured project.

---

## Lesson categories (overview)

| Topic | Notes |
|-------|--------|
| Basics, Greetings, Food, Family, Numbers, Colors, Travel | Intro vocabulary and phrases |
| Grammar: Nouns, Verbs, Adjectives, Pronouns, Prepositions | Structured grammar tracks |

Exact titles and order follow the data in the seed / database.

---

## Exercise types

1. **Word match** — tap pairs (Interslavic ↔ translation)
2. **Multiple choice** — pick one of four
3. **Fill in the blank** — type the missing word
4. **Text input** — type the translation

Wrong attempts show a **hint** first, not the full correct answer immediately.

---

## Resources & community

- [interslavic.fun](https://interslavic.fun/) — course hub  
- [interslavic-dictionary.com](https://interslavic-dictionary.com/)  
- [isv.miraheze.org](https://isv.miraheze.org/) — wiki  
- [github.com/medzuslovjansky](https://github.com/medzuslovjansky) — official OSS  
- [interslavic-language.org](https://interslavic-language.org/)

The app reserves **audioplayers** for future audio from these sources.

---

## License

[MIT](LICENSE)
