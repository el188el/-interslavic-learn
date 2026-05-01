import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/user_progress.dart';
import 'providers/app_providers.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for offline-first storage
  await Hive.initFlutter();
  Hive.registerAdapter(UserProgressAdapter());

  runApp(const ProviderScope(child: InterslavicLearnApp()));
}

class InterslavicLearnApp extends ConsumerStatefulWidget {
  const InterslavicLearnApp({super.key});

  @override
  ConsumerState<InterslavicLearnApp> createState() =>
      _InterslavicLearnAppState();
}

class _InterslavicLearnAppState extends ConsumerState<InterslavicLearnApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final dataService = ref.read(dataServiceProvider);
    final progressService = ref.read(progressServiceProvider);

    await progressService.init();
    await dataService.loadSeedData();

    // Update streak on app open
    ref.read(userProgressProvider.notifier).updateStreak();

    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Interslavic Learn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1565C0),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF1565C0),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: _initialized
          ? const HomeScreen()
          : Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.school, size: 64, color: Colors.blue),
                    const SizedBox(height: 16),
                    Text(
                      locale == 'ru'
                          ? 'Загрузка...'
                          : 'Loading...',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
    );
  }
}
