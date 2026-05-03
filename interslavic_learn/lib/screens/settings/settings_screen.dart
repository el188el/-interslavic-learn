import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../../widgets/app_chrome_background.dart';
import 'settings_sections.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(locale == 'ru' ? 'Настройки' : 'Settings'),
      ),
      body: AppChromeBackground(
        child: ListView(
          children: const [
            SettingsThemeSection(),
            Divider(height: 32),
            SettingsLanguageSection(),
            Divider(),
            SettingsScriptSection(),
            Divider(),
            SettingsResourcesSection(),
            Divider(),
            SettingsSupportSection(),
            Divider(),
            SettingsLegalSection(),
            Divider(),
            SettingsAboutSection(),
          ],
        ),
      ),
    );
  }
}
