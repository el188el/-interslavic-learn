# Contributing

Thank you for improving Interslavic Learn. This document is in **English** so contributors from any language community can follow the same process.

## Ways to help

- **Bug reports** — reproducible steps, device/OS, app version or commit hash, screenshots if UI-related.
- **Feature ideas** — open a discussion or issue describing the problem you solve, not only the solution.
- **Code** — small, focused pull requests are easier to review than large rewrites.
- **Course content** — grammar, wording, and exercise data live in the generator / seed pipeline (see `course_import/INSTRUCTIONS.txt` and `tool/`).

## Git workflow (branches and releases)

These rules apply to **maintainers** and anyone with push access; contributors still open PRs from forks as usual.

1. **One branch per meaningful change** — open a branch from `main` (e.g. `feature/sync-settings`, `fix/login-crash`). Push work-in-progress commits to that branch only.
2. **Merge to `main` when done** — use a merge commit or squash merge according to team preference; delete the feature branch after merge.
3. **Exception** — direct commits to `main` are allowed only for **small** edits (docs typo, one-line fix, config tweak) done by **one** person within **one working day**. Anything larger or longer-lived uses a branch.
4. **Releases = tags** — when `main` represents a release, create an **annotated** tag (e.g. `git tag -a v1.2.0 -m "Release 1.2.0"`). A tagged revision **must never be rewritten** (no force-push to that commit, no retagging the same version name to a different SHA). If something is wrong, cut a new tag (`v1.2.1`).
5. **History on GitHub** — after a one-time history reset, use `git push --force-with-lease origin main` only when the team agrees; remove obsolete remote branches and tags from the host if old history or stray tags should disappear for everyone.

## Before you code

1. **Scope** — comment on an existing issue or open one briefly describing the change, unless it is a trivial fix (typo, obvious crash).
2. **Secrets** — never commit `interslavic_learn/dart_defines.json`, `.env`, signing keys, or Supabase **service** keys. The app only needs the **anon** key at runtime; that key is still public-facing—treat the repo as untrusted for server-side secrets.
3. **Formatting** — follow existing style: `dart format` on changed Dart files, meaningful names, avoid unrelated refactors in the same PR.

## Project layout (where to change what)

| Area | Path |
|------|------|
| Flutter app | `interslavic_learn/` |
| Supabase schema & migrations | `supabase/` |
| Scraper (source site → JSON) | `scraper/` |
| Course JSON → SQL import | `tool/`, `course_import/` |
| Static landing (deployed separately) | `landing/` |

## Local checks (Flutter)

From `interslavic_learn/`:

```bash
flutter pub get
dart format lib test integration_test
flutter analyze
flutter test
```

Optional **integration smoke** (full `main()` — Hive, prefs, data load; slower). **Not on web:** `integration_test` does not support `-d chrome` yet; use the default test device, `-d windows`, or a mobile emulator.

```bash
cd interslavic_learn
flutter test integration_test
flutter test integration_test -d windows
```

Fix new analyzer issues in files you touch. If CI fails, update the PR until checks pass.

## Pull requests

- One logical change per PR when possible.
- Describe **what** and **why** in the PR text; link issues with `Fixes #123` when applicable.
- Update user-visible strings in both **Russian and English** if you add UI copy (the app toggles `ru` / `en`).

## Community tone

Be constructive and patient. Interslavic is a small language project; clear communication matters more than perfect English.

---

<details>
<summary>Кратко по-русски</summary>

Спасибо за вклад. Коротко: не коммитьте секреты (`dart_defines.json`, ключи подписи, service role Supabase). Маленькие PR с описанием «что и зачем». Перед отправкой: `dart format`, `flutter analyze`, `flutter test` в каталоге `interslavic_learn`. Строки интерфейса — по возможности на русском и английском. Для пуша в основной репозиторий: значимые изменения — отдельная ветка и слияние в `main`; исключения — только мелочь за один день; релизы — только теги, тег не переписывается.

</details>

<details>
<summary>Kratko po medžuslovjanskomu</summary>

Děkujemo za pomoč. Ne komitujte sekretov (ključe, `dart_defines.json` s paroljami). Male PR s jasnym opisom. Pśed wysyłanjem: `dart format`, `flutter analyze`, `flutter test` v papce `interslavic_learn`.

</details>
