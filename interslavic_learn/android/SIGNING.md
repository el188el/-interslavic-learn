# Подпись release для Android (локально и GitHub Actions)

Файлы **`upload-keystore.jks`** и **`key.properties`** не коммитьте — они в `.gitignore`.

---

## 1. Установите JDK (для `keytool`)

Нужна Java 17 (как в Gradle проекта). Варианты:

- [Eclipse Temurin 17](https://adoptium.net/) — установщик для Windows;
- или уже установленный Android Studio / JetBrains JDK.

Проверка в PowerShell:

```powershell
keytool -version
```

Если команда не найдена — добавьте в PATH каталог `bin` установленного JDK.

---

## 2. Создайте keystore (один раз на всё приложение)

В PowerShell перейдите в каталог `android` приложения:

```powershell
cd c:\projects\-interslavic-learn\interslavic_learn\android
```

Создайте файл **`upload-keystore.jks`** (имя можно другое, но тогда поправьте `storeFile` в `key.properties`):

```powershell
keytool -genkey -v `
  -keystore upload-keystore.jks `
  -alias upload `
  -keyalg RSA `
  -keysize 2048 `
  -validity 10000
```

Спросят:

- пароль хранилища (**store password**) — запомните;
- имя/организацию — можно произвольно для личного проекта;
- пароль ключа (**key password**) — часто ставят **тот же**, что и у хранилища.

**`-alias upload`** должен совпасть с **`keyAlias`** в `key.properties`.

Сделайте **резервную копию** `upload-keystore.jks` и паролей (без них обновления в RuStore под тем же ключом невозможны).

---

## 3. Локальный файл `key.properties`

В том же каталоге `android`:

```powershell
copy key.properties.example key.properties
```

Откройте **`key.properties`** и подставьте пароли и alias:

```properties
storePassword=ВАШ_ПАРОЛЬ_ХРАНИЛИЩА
keyPassword=ВАШ_ПАРОЛЬ_КЛЮЧА
keyAlias=upload
storeFile=../upload-keystore.jks
```

Путь **`storeFile`** указан относительно модуля **`app`** (`android/app/build.gradle.kks`): `../upload-keystore.jks` = файл **`android/upload-keystore.jks`**.

Сборка на своём ПК (если уже настроен Flutter и SDK):

```powershell
cd c:\projects\-interslavic-learn\interslavic_learn
flutter build apk --release
```

APK: `build/app/outputs/flutter-apk/app-release.apk`.

---

## 4. GitHub Actions — подпись в облаке

Workflow **Build Android APK** при наличии секретов сам создаёт **`upload-keystore.jks`** и **`key.properties`** на runner’е (файлы не попадают в репозиторий).

### 4.1. Секреты репозитория

GitHub → репозиторий → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**.

Создайте четыре секрета:

| Имя секрета | Содержимое |
|-------------|------------|
| `ANDROID_KEYSTORE_BASE64` | Содержимое файла keystore в Base64 (см. ниже) |
| `ANDROID_STORE_PASSWORD` | Пароль хранилища (`storePassword`) |
| `ANDROID_KEY_PASSWORD` | Пароль ключа (`keyPassword`) |
| `ANDROID_KEY_ALIAS` | Обычно `upload` (как `-alias` у keytool) |

Если **`ANDROID_KEYSTORE_BASE64`** не задан, сборка всё равно пройдёт, но APK будет подписан **debug-ключом** (как без локального keystore). Для RuStore задайте все четыре секрета.

### 4.2. Получить Base64 от `upload-keystore.jks` в PowerShell

На машине, где лежит файл keystore:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("c:\projects\-interslavic-learn\interslavic_learn\android\upload-keystore.jks")) | Set-Clipboard
```

Строка скопируется в буфер — вставьте её целиком в значение секрета **`ANDROID_KEYSTORE_BASE64`** (одна длинная строка без переносов).

Либу без PowerShell:

```powershell
certutil -encode upload-keystore.jks temp.b64
```

Возьмите текст из `temp.b64` между строками `BEGIN`/`END`, или используйте онлайн-конвертер только если доверяете источнику (для ключа лучше локально).

### 4.3. Запуск сборки

**Actions** → **Build Android APK** → **Run workflow**, или push в `main`/`master`. В артефакте **`app-release-apk`** будет подписанный release APK (если секреты заданы).

---

## 5. RuStore и обновления

- Загружайте в консоль RuStore тот APK/AAB, который подписан **вашим** release-keystore.
- Версия в `pubspec.yaml`: поле **`version:`** (`1.0.0+1` → следующий билд `1.0.1+2` и т.д.) должна расти для обновлений.

---

## 6. Частые проблемы

- **`keytool` не найден** — не в PATH; укажите полный путь к `keytool.exe` внутри установленного JDK.
- **Неверная подпись в CI** — проверьте, что Base64 полный, без пробелов; пароли и alias совпадают с теми, что при создании keystore.
- **Спецсимволы в пароле** — допустимы; секреты GitHub передаются в сборку как есть. Если локально Gradle ругается — проверьте кодировку файла `key.properties` (UTF-8).
