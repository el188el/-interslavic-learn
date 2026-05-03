/// Тексты политики конфиденальности (соответствуют фактическому поведению приложения).
abstract final class PrivacyPolicyTexts {
  static const lastUpdated = '2026-05-02';

  static String title(String locale) =>
      locale == 'ru' ? 'Политика конфиденциальности' : 'Privacy Policy';

  static List<PrivacySection> sections(String locale) =>
      locale == 'ru' ? _sectionsRu : _sectionsEn;
}

class PrivacySection {
  const PrivacySection({required this.heading, required this.body});

  final String heading;
  final String body;
}

final _sectionsRu = <PrivacySection>[
  PrivacySection(
    heading: '1. Общие положения',
    body:
        'Настоящая Политика описывает порядок обработки информации в мобильном приложении для изучения межславянского языка (далее — «Приложение»). '
        'Установка и использование Приложения означает, что вы ознакомились с настоящей Политикой.\n\n'
        'Ответственное лицо / контакт по вопросам персональных данных и реализации прав субъекта данных: электронная почта interslavic-app@yandex.ru.\n\n'
        'Приложение носит образовательный и неофициальный характер (контент о языке межславянском).',
  ),
  PrivacySection(
    heading: '2. Какие данные обрабатываются',
    body:
        'Режим без регистрации («гость»). На вашем устройстве локально (база данных Hive на телефоне/планшете) могут храниться:\n'
        '• отображаемое имя (никнейм в профиле);\n'
        '• учебный прогресс: сумма XP, текущая и лучшая серия занятий, дата активности;\n'
        '• список пройденных уроков и набранные за них баллы;\n'
        '• флаг премиум-доступа (например, отключение рекламы);\n'
        '• идентификатор связи с облаком (если позже выполнен вход).\n\n'
        'В настройках на устройстве также сохраняются предпочтения интерфейса (SharedPreferences): язык приложения (русский/английский), кириллица или латиница для межславянского, тема оформления (светлая/тёмная/системная), завершён ли онбординг, режим сессии (гость/облако).\n\n'
        'В режиме гостя указанные данные не отправляются разработчику автоматически и остаются на устройстве до удаления Приложения или очистки данных приложения в настройках ОС.\n\n'
        'Регистрация по электронной почте («облачный режим»). Для входа используется сервис Supabase (аутентификация и база данных на стороне сервера). Обрабатываются:\n'
        '• адрес электронной почты;\n'
        '• учётные данные для входа обрабатываются средствами Supabase Auth (пароль не передаётся разработчику в открытом виде);\n'
        '• уникальный идентификатор пользователя;\n'
        '• отображаемое имя в профиле;\n'
        '• те же сведения о прогрессе обучения, что и локально, для синхронизации между устройствами;\n'
        '• участие в общем рейтинге: в таблице лидеров могут отображаться ваше отображаемое имя, сумма XP и текущая серия среди других пользователей.\n\n'
        'Контент уроков подгружается из встроенных данных приложения и/или с сервера проекта (курсы); это не персональные данные о пользователе.',
  ),
  PrivacySection(
    heading: '3. Цели обработки',
    body:
        'Предоставление функций обучения; сохранение и восстановление прогресса; синхронизация между устройствами после входа в аккаунт; отображение рейтинга; поддержание работоспособности и безопасности Приложения.',
  ),
  PrivacySection(
    heading: '4. Российская Федерация (152-ФЗ)',
    body:
        'При распространении Приложения на территории РФ и в отношении граждан РФ обработка персональных данных осуществляется с учётом требований Федерального закона от 27.07.2006 № 152-ФЗ «О персональных данных». '
        'Субъект персональных данных вправе получить сведения об обработке, уточнить данные, потребовать прекращения неправомерной обработки и иным образом реализовать права, предусмотренные законом, направив запрос Оператору на контактный адрес электронной почты. '
        'В случае трансграничной передачи (п. 7) вы признаёте возможность передачи данных в инфраструктуру иностранного провайдера в объёме, необходимом для работы облачного режима.',
  ),
  PrivacySection(
    heading: '5. Европейская экономическая зона (GDPR)',
    body:
        'Если вы находитесь в ЕЭЗ, к вам могут применяться положения Общего регламента ЕС о защите данных (GDPR). '
        'Правовые основания обработки включают: исполнение функций Приложения по вашему запросу (предоставление сервиса); в необходимых случаях — ваше согласие, выраженное через регистрацию и использование облачных функций. '
        'Вы имеете право на доступ к данным, их исправление, удаление при отсутствии препятствующих оснований, ограничение обработки, переносимость данных в технически возможной части, отзыв согласия — через обращение на контактный e-mail и средствами учётной записи (удаление аккаунта у поставщика Supabase по их процедурам). '
        'Вы вправе подать жалобу в надзорный орган по месту жительства в ЕЭЗ.',
  ),
  PrivacySection(
    heading: '6. Иные страны',
    body:
        'Если применимо местное законодательство о защите данных (в т.ч. штаты США, Великобритания и др.), Оператор стремится соблюдать общие принципы минимизации данных, прозрачности и ваших прав на доступ и исправление через указанный контакт.',
  ),
  PrivacySection(
    heading: '7. Трансграничная передача и инфраструктура',
    body:
        'Серверы и сервис **Supabase** могут располагаться вне Российской Федерации и ЕЭЗ. Используя регистрацию и синхронизацию, вы понимаете, что данные учётной записи и прогресса обрабатываются указанным провайдером инфраструктуры. '
        'Актуальные условия и документы Supabase размещены на сайте https://supabase.com. Подключение к серверу осуществляется по защищённому протоколу HTTPS.',
  ),
  PrivacySection(
    heading: '8. Передача третьим лицам',
    body:
        'Разработчик не продаёт персональные данные. Передача ограничена технической необходимостью: обработка на стороне Supabase как поставщика аутентификации и базы данных. '
        'Иное раскрытие возможно только если это требуется по закону или по законному запросу уполномоченных органов.',
  ),
  PrivacySection(
    heading: '9. Срок хранения',
    body:
        'Локальные данные хранятся до удаления Приложения или данных приложения пользователем. '
        'Данные учётной записи на сервере хранятся до удаления аккаунта или иной процедуры у Supabase; выход из аккаунта в Приложении сам по себе не уничтожает серверную учётную запись.',
  ),
  PrivacySection(
    heading: '10. Безопасность',
    body:
        'Применяются обычные для клиент-серверных приложений меры: шифрование трафика при обмене с сервером. Абсолютную безопасность в сети Интернет гарантировать нельзя; пользователь также обязан хранить пароль в тайне.',
  ),
  PrivacySection(
    heading: '11. Дети',
    body:
        'Если по закону вашей страны для самостоятельного согласия на обработку данных требуется достижение определённого возраста, используйте Приложение при участии родителя или законного представителя.',
  ),
  PrivacySection(
    heading: '12. Аналитика и реклама',
    body:
        'У пользователей без премиум-доступа в нижней части экрана может отображаться рекламный баннер через SDK выбранного партнёра; состав обрабатываемых данных зависит от провайдера рекламы. '
        'Премиум отключает показ такой рекламы. Отдельные инструменты сквозной аналитики или поведенческой рекламы вне баннера в текущей версии могут не использоваться; при их подключении Политика будет обновлена. '
        'Рекомендуется периодически проверять актуальную редакцию в настройках.',
  ),
  PrivacySection(
    heading: '13. Изменения Политики',
    body:
        'Оператор вправе изменять настоящую Политику. Дата последнего обновления указана в начале экрана в Приложении. Продолжение использования после обновления может означать согласие с новой редакцией в частях, где это допускается применимым правом.',
  ),
  PrivacySection(
    heading: '14. Контакт',
    body: 'Электронная почта: interslavic-app@yandex.ru\n\n'
        'Текст Политики носит информационный характер и не заменяет индивидуальную юридическую консультацию.',
  ),
];

final _sectionsEn = <PrivacySection>[
  PrivacySection(
    heading: '1. Introduction',
    body:
        'This Privacy Policy describes how information is handled in the mobile application for learning Interslavic (the “App”). '
        'By installing and using the App, you acknowledge this Policy.\n\n'
        'Contact for privacy requests and exercising data-subject rights: interslavic-app@yandex.ru.\n\n'
        'The App is educational and unofficial (language-learning content).',
  ),
  PrivacySection(
    heading: '2. Data we process',
    body:
        'Guest mode (no registration). Locally on your device (Hive database) we may store:\n'
        '• display name;\n'
        '• learning progress: XP total, current and best streak, last activity date;\n'
        '• completed lessons and scores;\n'
        '• a premium flag (e.g. ad-free access);\n'
        '• an identifier linking to cloud login if you later sign in.\n\n'
        'Preferences (SharedPreferences) may include: app language (Russian/English), Cyrillic/Latin for Interslavic text, theme (light/dark/system), onboarding completion, session mode (guest/cloud).\n\n'
        'In guest mode, this information is not automatically transmitted to the developer and remains on your device until you uninstall the App or clear app data.\n\n'
        'Email registration (cloud mode). Authentication and server storage use Supabase. We process:\n'
        '• email address;\n'
        '• credentials handled by Supabase Auth (password is not visible to the developer in plain text);\n'
        '• unique user id;\n'
        '• profile display name;\n'
        '• the same learning progress data as locally, for sync across devices;\n'
        '• leaderboard participation: your display name, XP and streak may be shown among other users.\n\n'
        'Lesson content is loaded from bundled assets and/or project servers (courses); that content is not personal data about you.',
  ),
  PrivacySection(
    heading: '3. Purposes',
    body:
        'Providing learning features; saving progress; syncing after login; displaying rankings; maintaining reliability and security.',
  ),
  PrivacySection(
    heading: '4. Russia (Federal Law 152-FZ)',
    body:
        'Where the App is distributed in Russia and for Russian citizens, processing complies with Federal Law No. 152-FZ “On Personal Data”. '
        'You may request information about processing, rectification, blocking or deletion as permitted by law by emailing the contact address.',
  ),
  PrivacySection(
    heading: '5. European Economic Area (GDPR)',
    body:
        'If you are in the EEA, the GDPR may apply. Legal bases include performance of the service you request and, where required, consent (e.g. cloud registration). '
        'You have rights of access, rectification, erasure where applicable, restriction, data portability to the extent feasible, withdrawal of consent, and the right to lodge a complaint with a supervisory authority.',
  ),
  PrivacySection(
    heading: '6. Other jurisdictions',
    body:
        'Where other privacy laws apply, we aim to follow principles of data minimisation, transparency, and your rights of access and correction via the contact email.',
  ),
  PrivacySection(
    heading: '7. International transfers & infrastructure',
    body:
        'Supabase servers may be located outside Russia or the EEA. By using cloud features you acknowledge processing by that infrastructure provider. '
        'See https://supabase.com for their terms. Connections use HTTPS.',
  ),
  PrivacySection(
    heading: '8. Sharing with third parties',
    body:
        'We do not sell personal data. Sharing is limited to Supabase as the authentication/database provider. '
        'Further disclosure may occur if required by law or lawful authority requests.',
  ),
  PrivacySection(
    heading: '9. Retention',
    body:
        'Local data remains until you delete the App or app data. '
        'Account data on the server remains until you delete your account or as governed by Supabase procedures; signing out of the App does not automatically delete the server account.',
  ),
  PrivacySection(
    heading: '10. Security',
    body:
        'We use standard measures such as HTTPS for server communication. No method is 100% secure; protect your password.',
  ),
  PrivacySection(
    heading: '11. Children',
    body:
        'If your jurisdiction requires parental consent below a certain age, use the App with a parent or guardian.',
  ),
  PrivacySection(
    heading: '12. Analytics & advertising',
    body:
        'For users without premium, an advertising banner may appear at the bottom of the screen via a partner advertising SDK; what data is processed depends on that provider. Premium removes such ads. '
        'Additional cross-app analytics or behavioural ad SDKs may not be used in the current build; if they are added, this Policy will be updated. Check the in-app “last updated” date periodically.',
  ),
  PrivacySection(
    heading: '13. Changes',
    body:
        'We may update this Policy. The “last updated” date is shown in the App. Continued use after changes may imply acceptance where permitted by law.',
  ),
  PrivacySection(
    heading: '14. Contact',
    body: 'Email: interslavic-app@yandex.ru\n\n'
        'This Policy is informational and does not replace legal advice.',
  ),
];
