Статический лендинг в КОРНЕ сайта GitHub Pages.

Деплой: workflow копирует landing/ → _site/, Flutter Web → _site/app/,
APK → _site/downloads/learn_interslavic_<версия>.apk (см. .github/workflows/deploy_web.yml).

В index.html в ссылке на APK стоит плейсхолдер __LEARN_APK_BASENAME__ — при сборке сайта
CI заменяет его на реальное имя файла (с версией из pubspec.yaml), чтобы скачивание
шло под именем вида learn_interslavic_1.0.1.apk.

Ссылки на лендинге после деплоя:
  ./app/ — веб-приложение
  downloads/learn_interslavic_<версия>.apk — Android APK

Локально при открытии landing/index.html с диска ссылка на APK не сработает (плейсхолдер не заменён) — это нормально.

RuStore: в index.html замените кнопку-заглушку на <a href="https://apps.rustore.ru/..."> когда появится карточка приложения.

Свой домен: GitHub Pages → Custom domain; при корне домена настройте base-href для Flutter (см. .github/WEB_DEPLOY.txt).
