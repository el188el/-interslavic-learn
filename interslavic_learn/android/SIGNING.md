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

APK после сборки (имя совпадает с версией в `pubspec.yaml`): `build/app/outputs/flutter-apk/learn_interslavic_<versionName>.apk` (см. также `release/apk_output_name.txt`).

---

## 4. GitHub Actions — подпись в облаке (пошагово)

Секреты может создать **только владелец** репозитория на GitHub; сделать это за вас из чата нельзя. Ниже — что нажимать, **в каком порядке**.

> В workflow нельзя писать `if: ${{ secrets.XXX }}` — GitHub отклоняет файл. Проверка «секрет задан или нет» делается внутри shell-шага в `.github/workflows/build_apk.yml`.

Workflow **Build Android APK** при правильных секретах подставит keystore на сервере. Без секрета `ANDROID_KEYSTORE_BASE64` APK в CI будет с **debug**-подписью (для RuStore не подойдёт).

### Шаг 1. Скопировать keystore в буфер обмена (на вашем ПК)

Откройте **PowerShell** и выполните **одну** команду (путь оставьте таким, если `upload-keystore.jks` лежит в `android`):

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("c:\projects\-interslavic-learn\interslavic_learn\android\upload-keystore.jks")) | Set-Clipboard
```

Ошибок быть не должно. В буфере обмена теперь **одна очень длинная строка** — её не редактируйте.

### Шаг 2. Открыть страницу секретов на GitHub

1. Зайдите на **github.com** и откройте **ваш репозиторий** с проектом (не чужой форк без прав).
2. Вверху вкладка **Settings** (Настройки).
3. Слева меню: **Secrets and variables** → **Actions**.
4. Кнопка **New repository secret** (Новый секрет репозитория).

Дальше вы **четыре раза** нажимаете **New repository secret** и каждый раз заполняете **Name** и **Secret** строго как ниже.

### Шаг 3. Первый секрет — файл ключа в Base64

1. **Name** (имя) — скопируйте **буквально**, без пробелов в начале/конце:

   `ANDROID_KEYSTORE_BASE64`

2. **Secret** (значение) — вставьте из буфера (**Ctrl+V**): та самая длинная строка из шага 1.

3. **Add secret** (Добавить секрет).

### Шаг 4. Второй секрет — пароль хранилища

1. Снова **New repository secret**.
2. **Name:** `ANDROID_STORE_PASSWORD`
3. **Secret:** тот же пароль, что у вас в `key.properties` в строке **`storePassword=`** (или что вы вводили для keystore при `keytool`).
4. **Add secret**.

### Шаг 5. Третий секрет — пароль ключа

1. **New repository secret**.
2. **Name:** `ANDROID_KEY_PASSWORD`
3. **Secret:** то же, что в `key.properties` в строке **`keyPassword=`**.
4. **Add secret**.

### Шаг 6. Четвёртый секрет — alias

1. **New repository secret**.
2. **Name:** `ANDROID_KEY_ALIAS`
3. **Secret:** одно слово без кавычек: `upload`  
   (так вы создавали ключ: `-alias upload`. Если делали другой alias — вставьте **его**.)
4. **Add secret**.

### Шаг 7. Проверить список

На странице **Actions** секретов должны быть **ровно эти четыре имени**:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_STORE_PASSWORD`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_KEY_ALIAS`

Имена **чувствительны к регистру** — только большие буквы и подчёркивания, как в списке.

### Шаг 8. Запустить сборку

1. Вкладка репозитория **Actions**.
2. Слева выберите workflow **Build Android APK**.
3. Справа **Run workflow** → выберите ветку (часто **main**) → **Run workflow**.
4. Дождитесь зелёной галочки.
5. Откройте этот запуск → внизу **Artifacts** → скачайте **app-release-apk**.

Если сборка красная — откройте шаг **Build APK**, прочитайте текст ошибки (часто неверный пароль или обрезанный Base64).

**Без PowerShell:** в каталоге `android` можно выполнить `certutil -encode upload-keystore.jks temp.b64`, затем открыть `temp.b64`, удалить первую и последнюю строки (`BEGIN` / `END`), оставшиеся строки Base64 **склеить в одну длинную строку без пробелов** и вставить в секрет `ANDROID_KEYSTORE_BASE64`. Проще всего — команда PowerShell из шага 1.

Не загружайте keystore на сторонние сайты для конвертации в Base64.

---

## 5. RuStore и обновления

- Загружайте в консоль RuStore тот APK/AAB, который подписан **вашим** release-keystore.
- Версия в `pubspec.yaml`: поле **`version:`** (`1.0.0+1` → следующий билд `1.0.1+2` и т.д.) должна расти для обновлений.

---

## 6. Частые проблемы

- **`keytool` не найден** — не в PATH; укажите полный путь к `keytool.exe` внутри установленного JDK.
- **Неверная подпись в CI** — проверьте, что Base64 полный, без пробелов; пароли и alias совпадают с теми, что при создании keystore.
- **Спецсимволы в пароле** — допустимы; секреты GitHub передаются в сборку как есть. Если локально Gradle ругается — проверьте кодировку файла `key.properties` (UTF-8).
