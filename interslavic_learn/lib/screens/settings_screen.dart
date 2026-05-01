import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';

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
      body: ListView(
        children: [
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
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(locale == 'ru'
                ? 'Источник данных'
                : 'Data Source'),
            subtitle: const Text('interslavic.fun'),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: Text(locale == 'ru'
                ? 'Открытый исходный код'
                : 'Open Source'),
            subtitle: Text(locale == 'ru'
                ? 'Данные грамматики: medzuslovjansky.github.io'
                : 'Grammar data: medzuslovjansky.github.io'),
          ),
        ],
      ),
    );
  }
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
