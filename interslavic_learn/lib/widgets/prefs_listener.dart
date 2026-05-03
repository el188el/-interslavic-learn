import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';

/// Сохраняет язык и письменность в SharedPreferences при изменении.
class PrefsListener extends ConsumerStatefulWidget {
  const PrefsListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PrefsListener> createState() => _PrefsListenerState();
}

class _PrefsListenerState extends ConsumerState<PrefsListener> {
  @override
  Widget build(BuildContext context) {
    ref.listen(localeProvider, (_, next) {
      ref.read(preferencesServiceProvider).setLocale(next);
    });
    ref.listen(useCyrillicProvider, (_, next) {
      ref.read(preferencesServiceProvider).setUseCyrillic(next);
    });
    ref.listen(themePreferenceProvider, (_, next) {
      ref.read(preferencesServiceProvider).setThemeModeRaw(next.name);
    });
    return widget.child;
  }
}
