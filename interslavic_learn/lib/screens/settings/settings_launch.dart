import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../errors/app_error_codes.dart' show AppErrorCodes, formatUserError;
import 'settings_constants.dart';

Future<void> openSettingsExternalUrl(
  BuildContext context,
  String url,
  String locale,
) async {
  final uri = Uri.parse(url);
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    final isRu = locale == 'ru';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          formatUserError(
            isRu: isRu,
            code: AppErrorCodes.settingsOpenUrlFailed,
            headlineRu: 'Не удалось открыть ссылку.',
            headlineEn: 'Could not open link.',
          ),
        ),
      ),
    );
  }
}

Future<void> launchSettingsMailto(BuildContext context, String locale) async {
  final uri = Uri(
    scheme: 'mailto',
    path: kDeveloperEmail,
    queryParameters: {
      'subject': 'Interslavic app',
    },
  );
  final ok = await launchUrl(uri);
  if (!ok && context.mounted) {
    final isRu = locale == 'ru';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          formatUserError(
            isRu: isRu,
            code: AppErrorCodes.settingsOpenMailFailed,
            headlineRu: 'Не удалось открыть почту.',
            headlineEn: 'Could not open mail app.',
          ),
        ),
      ),
    );
  }
}
