Интеграционный smoke с реальным main() и Hive — каталог проекта:
  interslavic_learn/integration_test/

Запуск (из каталога interslavic_learn), без веб-устройства:
  flutter test integration_test
  flutter test integration_test -d windows

Веб (`-d chrome`) для integration_test в Flutter пока не поддерживается — smoke
в integration_test/app_smoke_test.dart на kIsWeb помечен skip.

Обычный `flutter test` без пути выполняет только тесты в test/ и не трогает integration_test/.
