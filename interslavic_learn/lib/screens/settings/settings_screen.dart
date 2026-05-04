import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../../services/feedback_service.dart';
import '../../widgets/app_chrome_background.dart';
import '../../widgets/course_feedback_bar.dart';
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
          children: [
            const SettingsThemeSection(),
            const Divider(height: 32),
            const SettingsLanguageSection(),
            const Divider(),
            const SettingsScriptSection(),
            const Divider(),
            const SettingsResourcesSection(),
            const Divider(),
            const SettingsSupportSection(),
            const Divider(),
            const SettingsLegalSection(),
            const Divider(),
            const SettingsAboutSection(),
            const SizedBox(height: 8),
            const CourseFeedbackBar(screen: FeedbackScreenKind.settings),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
