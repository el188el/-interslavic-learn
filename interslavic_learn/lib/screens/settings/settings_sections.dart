import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../legal/privacy_policy_screen.dart';
import 'settings_constants.dart';
import 'settings_launch.dart';
import 'settings_resources.dart';
import 'settings_section_header.dart';

class SettingsThemeSection extends ConsumerWidget {
  const SettingsThemeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionHeader(
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
      ],
    );
  }
}

class SettingsLanguageSection extends ConsumerWidget {
  const SettingsLanguageSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionHeader(
          title: locale == 'ru' ? 'Язык приложения' : 'App Language',
        ),
        ListTile(
          title: const Text('Русский'),
          leading: Icon(
            locale == 'ru'
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: locale == 'ru'
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
          onTap: () => ref.read(localeProvider.notifier).state = 'ru',
        ),
        ListTile(
          title: const Text('English'),
          leading: Icon(
            locale == 'en'
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: locale == 'en'
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
          onTap: () => ref.read(localeProvider.notifier).state = 'en',
        ),
      ],
    );
  }
}

class SettingsScriptSection extends ConsumerWidget {
  const SettingsScriptSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final useCyrillic = ref.watch(useCyrillicProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionHeader(
          title: locale == 'ru'
              ? 'Письменность межславянского'
              : 'Interslavic Script',
        ),
        SwitchListTile(
          title: Text(
            locale == 'ru'
                ? 'Использовать кириллицу'
                : 'Use Cyrillic script',
          ),
          subtitle: Text(
            useCyrillic
                ? (locale == 'ru' ? 'Кириллица (Кир)' : 'Cyrillic (Кир)')
                : (locale == 'ru' ? 'Латиница (Lat)' : 'Latin (Lat)'),
          ),
          value: useCyrillic,
          onChanged: (v) => ref.read(useCyrillicProvider.notifier).state = v,
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
      ],
    );
  }
}

class SettingsResourcesSection extends ConsumerWidget {
  const SettingsResourcesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionHeader(
          title: locale == 'ru' ? 'Ресурсы' : 'Resources',
        ),
        ...buildSettingsResourceTiles(context, locale),
      ],
    );
  }
}

class SettingsSupportSection extends ConsumerWidget {
  const SettingsSupportSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionHeader(
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
          onTap: () => launchSettingsMailto(context, locale),
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
          onTap: () => openSettingsExternalUrl(context, kDonateUrl, locale),
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
      ],
    );
  }
}

class SettingsLegalSection extends ConsumerWidget {
  const SettingsLegalSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionHeader(
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
      ],
    );
  }
}

class SettingsAboutSection extends ConsumerWidget {
  const SettingsAboutSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionHeader(
          title: locale == 'ru' ? 'О приложении' : 'About',
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(locale == 'ru' ? 'Версия' : 'Version'),
          subtitle: const Text('1.0.0 (MVP)'),
        ),
      ],
    );
  }
}
