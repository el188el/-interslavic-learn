import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_providers.dart';
import '../widgets/app_chrome_background.dart';
import 'legal/privacy_policy_screen.dart';

/// Контакты и поддержка (фиксированные значения).
const String kDeveloperEmail = 'interslavic-app@yandex.ru';
const String kDonateUrl = 'https://pay.cloudtips.ru/p/8283b392';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final useCyrillic = ref.watch(useCyrillicProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(locale == 'ru' ? 'Настройки' : 'Settings'),
      ),
      body: AppChromeBackground(
        child: ListView(
        children: [
          _SectionHeader(
            title: locale == 'ru' ? 'Тема' : 'Theme',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<AppThemePreference>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment<AppThemePreference>(
                  value: AppThemePreference.system,
                  icon: const Icon(Icons.brightness_auto_rounded, size: 20),
                  label: Text(locale == 'ru' ? 'Авто' : 'Auto'),
                ),
                ButtonSegment<AppThemePreference>(
                  value: AppThemePreference.light,
                  icon: const Icon(Icons.light_mode_rounded, size: 20),
                  label: Text(locale == 'ru' ? 'Свет' : 'Light'),
                ),
                ButtonSegment<AppThemePreference>(
                  value: AppThemePreference.dark,
                  icon: const Icon(Icons.dark_mode_rounded, size: 20),
                  label: Text(locale == 'ru' ? 'Тёмн.' : 'Dark'),
                ),
              ],
              selected: {ref.watch(themePreferenceProvider)},
              onSelectionChanged: (next) {
                ref.read(themePreferenceProvider.notifier).state = next.first;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Text(
              locale == 'ru'
                  ? '«Авто» берёт светлую или тёмную тему из настроек устройства.'
                  : '“Auto” follows your device light/dark appearance.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),

          const Divider(height: 32),

          // Language section
          _SectionHeader(
            title: locale == 'ru' ? 'Язык приложения' : 'App Language',
          ),
          ListTile(
            title: const Text('Русский'),
            leading: Icon(
              locale == 'ru' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: locale == 'ru' ? Theme.of(context).colorScheme.primary : null,
            ),
            onTap: () =>
                ref.read(localeProvider.notifier).state = 'ru',
          ),
          ListTile(
            title: const Text('English'),
            leading: Icon(
              locale == 'en' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: locale == 'en' ? Theme.of(context).colorScheme.primary : null,
            ),
            onTap: () =>
                ref.read(localeProvider.notifier).state = 'en',
          ),

          const Divider(),

          // Script section
          _SectionHeader(
            title: locale == 'ru'
                ? 'Письменность межславянского'
                : 'Interslavic Script',
          ),
          SwitchListTile(
            title: Text(locale == 'ru'
                ? 'Использовать кириллицу'
                : 'Use Cyrillic script'),
            subtitle: Text(useCyrillic
                ? (locale == 'ru' ? 'Кириллица (Кир)' : 'Cyrillic (Кир)')
                : (locale == 'ru' ? 'Латиница (Lat)' : 'Latin (Lat)')),
            value: useCyrillic,
            onChanged: (v) =>
                ref.read(useCyrillicProvider.notifier).state = v,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              locale == 'ru'
                  ? 'В заданиях с вводом текста над полем есть кнопки букв č, š, ј и др. На ПК можно поставить отдельную раскладку — см. «Ресурсы».'
                  : 'In typing exercises, special letters (č, š, ј, …) appear above the field. On desktop you can install a dedicated keyboard layout — see Resources.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),

          const Divider(),

          // External resources
          _SectionHeader(
            title: locale == 'ru' ? 'Ресурсы' : 'Resources',
          ),
          ..._resourceTiles(context, locale),

          const Divider(),

          _SectionHeader(
            title: locale == 'ru'
                ? 'Разработчик и поддержка'
                : 'Developer & support',
          ),
          ListTile(
            leading: Icon(
              Icons.alternate_email_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(locale == 'ru' ? 'Электронная почта' : 'Email'),
            subtitle: SelectableText(
              kDeveloperEmail,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.mail_outline_rounded),
            title: Text(locale == 'ru' ? 'Написать письмо' : 'Send email'),
            subtitle: Text(
              locale == 'ru'
                  ? 'Откроется почтовый клиент'
                  : 'Opens your mail app',
            ),
            trailing: const Icon(Icons.open_in_new_rounded),
            onTap: () => _launchMailto(context, locale),
          ),
          ListTile(
            leading: Icon(
              Icons.volunteer_activism_rounded,
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: Text(
              locale == 'ru'
                  ? 'Поддержать разработчика'
                  : 'Support the developer',
            ),
            subtitle: Text(
              locale == 'ru'
                  ? 'CloudTips — добровольный донат'
                  : 'CloudTips — voluntary tip',
            ),
            trailing: const Icon(Icons.open_in_new_rounded),
            onTap: () => _openExternalUrl(context, kDonateUrl, locale),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              locale == 'ru'
                  ? 'Отзывы и предложения приветствуются. Если заметили ошибку в уроке или в приложении — напишите на почту.'
                  : 'Feedback is welcome. If you spot a mistake in a lesson or the app — email us.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              locale == 'ru'
                  ? 'Приложение образовательное и неофициальное. Прогресс по умолчанию хранится на устройстве; при входе по email данные синхронизируются с сервером проекта.'
                  : 'This is an unofficial educational app. Progress is stored on your device by default; with email login it syncs to the project server.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),

          const Divider(),

          _SectionHeader(
            title: locale == 'ru' ? 'Документы' : 'Legal',
          ),
          ListTile(
            leading: Icon(
              Icons.privacy_tip_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              locale == 'ru'
                  ? 'Политика конфиденциальности'
                  : 'Privacy Policy',
            ),
            subtitle: Text(
              locale == 'ru'
                  ? 'Какие данные хранятся и ваши права (РФ, ЕС и др.)'
                  : 'What we store and your rights (RU, EU, etc.)',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),

          const Divider(),

          // About section
          _SectionHeader(
            title: locale == 'ru' ? 'О приложении' : 'About',
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(locale == 'ru'
                ? 'Версия'
                : 'Version'),
            subtitle: const Text('1.0.0 (MVP)'),
          ),
        ],
        ),
      ),
    );
  }
}

Future<void> _openExternalUrl(
  BuildContext context,
  String url,
  String locale,
) async {
  final uri = Uri.parse(url);
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          locale == 'ru' ? 'Не удалось открыть ссылку' : 'Could not open link',
        ),
      ),
    );
  }
}

Future<void> _launchMailto(BuildContext context, String locale) async {
  final uri = Uri(
    scheme: 'mailto',
    path: kDeveloperEmail,
    queryParameters: {
      'subject': 'Interslavic app',
    },
  );
  final ok = await launchUrl(uri);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          locale == 'ru'
              ? 'Не удалось открыть почту'
              : 'Could not open mail app',
        ),
      ),
    );
  }
}

List<Widget> _resourceTiles(BuildContext context, String locale) {
  final isRu = locale == 'ru';
  const items = <_ResourceItem>[
    _ResourceItem(
      url: 'https://interslavic.fun',
      titleRu: 'Interslavic.fun',
      titleEn: 'Interslavic.fun',
      subtitleRu: 'Сайт и учебные материалы',
      subtitleEn: 'Site and learning materials',
    ),
    _ResourceItem(
      url: 'https://interslavic-dictionary.com',
      titleRu: 'Словарь (онлайн)',
      titleEn: 'Online dictionary',
      subtitleRu: 'interslavic-dictionary.com',
      subtitleEn: 'interslavic-dictionary.com',
    ),
    _ResourceItem(
      url: 'https://isv.miraheze.org',
      titleRu: 'Вики',
      titleEn: 'Wiki',
      subtitleRu: 'Справочник на Miraheze',
      subtitleEn: 'Miraheze wiki',
    ),
    _ResourceItem(
      url: 'https://steen.free.fr/interslavic',
      titleRu: 'Курс Jan van Steenbergen',
      titleEn: "Jan van Steenbergen's course",
      subtitleRu: 'steen.free.fr/interslavic',
      subtitleEn: 'steen.free.fr/interslavic',
    ),
    _ResourceItem(
      url: 'https://github.com/medzuslovjansky',
      titleRu: 'Проект Medžuslovjansky (GitHub)',
      titleEn: 'Medžuslovjansky project (GitHub)',
      subtitleRu: 'Грамматика, словари, инструменты',
      subtitleEn: 'Grammar, lexicons, tooling',
    ),
    _ResourceItem(
      url: 'https://github.com/sonic16x/interslavic',
      titleRu: 'Словарь Sonic16x (GitHub)',
      titleEn: 'Sonic16x interslavic (GitHub)',
      subtitleRu: 'Исходный код веб-словаря',
      subtitleEn: 'Web dictionary source',
    ),
    _ResourceItem(
      url: 'https://interslavic-language.org',
      titleRu: 'Межславянский язык',
      titleEn: 'Interslavic language',
      subtitleRu: 'interslavic-language.org',
      subtitleEn: 'interslavic-language.org',
    ),
    _ResourceItem(
      url: 'http://tyflonet.com/siciliano/klaviatury',
      titleRu: 'Раскладки клавиатуры (Tyflonet)',
      titleEn: 'Keyboard layouts (Tyflonet)',
      subtitleRu: 'Специальные MSKLC / раскладки для славянских языков',
      subtitleEn: 'MSKLC-style layouts for Slavic typing',
    ),
    _ResourceItem(
      url: 'http://usachov.eu/g',
      titleRu: 'Клавиатуры и ввод (usachov.eu)',
      titleEn: 'Keyboards & input (usachov.eu)',
      subtitleRu: 'Дополнительные материалы по вводу',
      subtitleEn: 'More typing resources',
    ),
    _ResourceItem(
      url: 'https://www.sostav.ru/blogs/288561/82696',
      titleRu: 'Статья о раскладках (Sostav.ru)',
      titleEn: 'Article on keyboard layouts (Sostav.ru)',
      subtitleRu: 'Блог про клавиатуры для славянских языков',
      subtitleEn: 'Blog post about Slavic keyboard layouts',
    ),
  ];

  return items
      .map(
        (e) => ListTile(
          leading: const Icon(Icons.open_in_new),
          title: Text(isRu ? e.titleRu : e.titleEn),
          subtitle: Text(isRu ? e.subtitleRu : e.subtitleEn),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _openExternalUrl(context, e.url, locale),
        ),
      )
      .toList();
}

class _ResourceItem {
  const _ResourceItem({
    required this.url,
    required this.titleRu,
    required this.titleEn,
    required this.subtitleRu,
    required this.subtitleEn,
  });

  final String url;
  final String titleRu;
  final String titleEn;
  final String subtitleRu;
  final String subtitleEn;
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
