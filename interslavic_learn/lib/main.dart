import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/user_progress.dart';
import 'providers/app_providers.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'services/course_catalog_revision.dart';
import 'services/guest_session.dart';
import 'services/preferences_service.dart';
import 'services/sync_service.dart';
import 'services/supabase_service.dart';
import 'app_navigator.dart';
import 'theme/app_theme.dart';
import 'widgets/app_chrome_background.dart';
import 'widgets/prefs_listener.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await PreferencesService.create();
  await Hive.initFlutter();
  Hive.registerAdapter(UserProgressAdapter());

  await initSupabaseIfConfigured();

  final sessionInit = prefs.sessionModeRaw == 'cloud'
      ? SessionMode.cloud
      : SessionMode.guest;

  runApp(
    ProviderScope(
      overrides: [
        preferencesServiceProvider.overrideWithValue(prefs),
        localeProvider.overrideWith((ref) => prefs.locale),
        useCyrillicProvider.overrideWith((ref) => prefs.useCyrillic),
        sessionModeProvider.overrideWith((ref) => sessionInit),
        onboardingCompleteProvider
            .overrideWith((ref) => prefs.onboardingComplete),
        guestBannerDismissedProvider
            .overrideWith((ref) => prefs.guestBannerDismissed),
        themePreferenceProvider.overrideWith(
          (ref) => appThemePreferenceFromRaw(prefs.themeModeRaw),
        ),
      ],
      child: const PrefsListener(
        child: InterslavicLearnApp(),
      ),
    ),
  );
}

class InterslavicLearnApp extends ConsumerStatefulWidget {
  const InterslavicLearnApp({super.key});

  @override
  ConsumerState<InterslavicLearnApp> createState() =>
      _InterslavicLearnAppState();
}

class _InterslavicLearnAppState extends ConsumerState<InterslavicLearnApp>
    with WidgetsBindingObserver {
  bool _initialized = false;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_checkCourseCatalogRevisionOnResume());
    }
  }

  Future<void> _checkCourseCatalogRevisionOnResume() async {
    if (!_initialized) return;
    if (!isSupabaseConfigured) return;
    final data = ref.read(dataServiceProvider);
    if (!data.loadedFromRemote) return;
    final R = await fetchCourseCatalogRevision();
    if (R == null) return;
    final ack = ref.read(preferencesServiceProvider).courseCatalogRevisionAck;
    if (ack != null && R > ack) {
      ref.read(courseUpdateBannerVisibleProvider.notifier).state = true;
    }
  }

  Future<void> _syncCourseRevisionAckAfterLoad() async {
    if (!isSupabaseConfigured) return;
    final data = ref.read(dataServiceProvider);
    if (!data.loadedFromRemote) return;
    final R = await fetchCourseCatalogRevision();
    if (R != null) {
      await ref.read(preferencesServiceProvider).setCourseCatalogRevisionAck(R);
    }
  }

  Future<void> _presentCourseUpdateBanner() async {
    final sm = _scaffoldMessengerKey.currentState;
    if (sm == null) return;
    final ru = ref.read(localeProvider) == 'ru';
    sm.hideCurrentMaterialBanner();
    sm.showMaterialBanner(
      MaterialBanner(
        content: Text(
          ru
              ? 'На сервере обновились курсы. Загрузите новую версию списка уроков.'
              : 'Course content was updated on the server. Load the latest lessons.',
        ),
        leading: const Icon(Icons.cloud_download_outlined),
        actions: [
          TextButton(
            onPressed: () async {
              sm.hideCurrentMaterialBanner();
              ref.read(courseUpdateBannerVisibleProvider.notifier).state = false;
              final data = ref.read(dataServiceProvider);
              await data.reloadFromRemote();
              final R = await fetchCourseCatalogRevision();
              if (R != null) {
                await ref
                    .read(preferencesServiceProvider)
                    .setCourseCatalogRevisionAck(R);
              }
              if (!mounted) return;
              sm.showSnackBar(
                SnackBar(
                  content: Text(
                    ru ? 'Курсы обновлены' : 'Courses updated',
                  ),
                ),
              );
            },
            child: Text(ru ? 'Загрузить' : 'Load'),
          ),
          TextButton(
            onPressed: () {
              sm.hideCurrentMaterialBanner();
              ref.read(courseUpdateBannerVisibleProvider.notifier).state = false;
            },
            child: Text(ru ? 'Позже' : 'Later'),
          ),
        ],
      ),
    );
  }

  Future<void> _init() async {
    final dataService = ref.read(dataServiceProvider);
    final progressService = ref.read(progressServiceProvider);

    await progressService.init();
    await dataService.loadAll();
    await _syncCourseRevisionAckAfterLoad();

    final session = ref.read(sessionModeProvider);
    if (session == SessionMode.guest) {
      await GuestSession.ensure(progressService);
      ref.read(userProgressProvider.notifier).refresh();
    } else if (session == SessionMode.cloud && isSupabaseConfigured) {
      final uid = supabaseOrNull?.auth.currentUser?.id;
      if (uid != null) {
        await SyncService(progressService).pullCloudProgressToLocal();
        ref.read(userProgressProvider.notifier).refresh();
      }
    }

    // Серия начисляется при завершении урока, не при каждом запуске приложения.

    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingDone = ref.watch(onboardingCompleteProvider);
    final themePref = ref.watch(themePreferenceProvider);

    ref.listen<bool>(courseUpdateBannerVisibleProvider, (prev, next) {
      if (next) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && ref.read(courseUpdateBannerVisibleProvider)) {
            unawaited(_presentCourseUpdateBanner());
          }
        });
      }
    });

    return MaterialApp(
      scaffoldMessengerKey: _scaffoldMessengerKey,
      navigatorKey: appNavigatorKey,
      title: 'Interslavic Learn',
      debugShowCheckedModeBanner: false,
      theme: buildDuoLightTheme(),
      darkTheme: buildDuoDarkTheme(),
      themeMode: themeModeFromPreference(themePref),
      home: !_initialized
          ? const _SplashBody()
          : onboardingDone
              ? const HomeScreen()
              : const WelcomeScreen(),
    );
  }
}

class _SplashBody extends ConsumerWidget {
  const _SplashBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppChromeBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Image.asset(
              'assets/branding/app_icon.png',
              width: 112,
              height: 112,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
            ),
            const SizedBox(height: 16),
            Text(
              locale == 'ru' ? 'Загрузка...' : 'Loading...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
